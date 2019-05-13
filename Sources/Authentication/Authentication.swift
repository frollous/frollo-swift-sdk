//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CoreData
import Foundation

#if os(iOS) && CORE
import AppAuthCore
#else
import AppAuth
#endif

#if os(iOS) && !CORE
import SafariServices
import UIKit
#endif

internal protocol AuthenticationDelegate: AnyObject {
    
    func authenticationReset()
    
}

/**
 Authentication
 
 Manages authentication, login, registration, logout and the user profile.
 */
public class Authentication {
    
    /**
     Indicates if the user is currently authorised with Frollo
     */
    public internal(set) var loggedIn: Bool {
        get {
            return preferences.loggedIn
        }
        set {
            preferences.loggedIn = newValue
        }
    }
    
    internal var authorizationFlow: OIDExternalUserAgentSession?
    
    private let authService: OAuthService
    private let clientID: String
    private let database: Database
    private let domain: String
    private let networkAuthenticator: NetworkAuthenticator
    private let preferences: Preferences
    private let serverURL: URL
    
    private weak var delegate: AuthenticationDelegate?
    
    init(database: Database, clientID: String, serverURL: URL, networkAuthenticator: NetworkAuthenticator, authService: OAuthService, preferences: Preferences, delegate: AuthenticationDelegate?) {
        self.database = database
        self.clientID = clientID
        self.domain = serverURL.host ?? serverURL.absoluteString
        self.networkAuthenticator = networkAuthenticator
        self.authService = authService
        self.preferences = preferences
        self.serverURL = serverURL
        self.delegate = delegate
        
        networkAuthenticator.authentication = self
    }
    
    // MARK: - Login
    
    #if os(iOS) && !CORE
    /**
     Login a user via web view
     
     Initiate the authorization code login flow using a web view
     
     - parameters:
        - presentingViewController: View controller the Safari Web ViewController should be presented from
        - completion: Completion handler with any error that occurred
     */
    public func loginUserUsingWeb(presenting presentingViewController: UIViewController, completion: @escaping FrolloSDKCompletionHandler) {
        let config = OIDServiceConfiguration(authorizationEndpoint: authService.authorizationURL, tokenEndpoint: authService.tokenURL)
        
        let request = OIDAuthorizationRequest(configuration: config,
                                              clientId: clientID,
                                              clientSecret: nil,
                                              scopes: [OAuthTokenRequest.Scope.offlineAccess.rawValue, OIDScopeOpenID, OIDScopeEmail],
                                              redirectURL: authService.redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["audience": serverURL.absoluteString, "domain": domain])
        
        authorizationFlow = OIDAuthorizationService.present(request, presenting: presentingViewController) { response, error in
            if let authError = error as NSError? {
                let oAuthError = OAuth2Error(error: authError)
                
                DispatchQueue.main.async {
                    completion(.failure(oAuthError))
                }
            } else if let authResponse = response,
                let authCode = authResponse.authorizationCode,
                let codeVerifier = request.codeVerifier {
                self.exchangeAuthorizationCode(code: authCode, codeVerifier: codeVerifier, completion: completion)
            }
        }
    }
    #endif
    
    #if os(macOS)
    /**
     Login a user via web view
     
     Initiate the authorization code login flow using a web view
     
     - parameters:
        - completion: Completion handler with any error that occurred
     */
    public func loginUserUsingWeb(completion: @escaping FrolloSDKCompletionHandler) {
        let config = OIDServiceConfiguration(authorizationEndpoint: authService.authorizationURL, tokenEndpoint: authService.tokenURL)
        
        let request = OIDAuthorizationRequest(configuration: config,
                                              clientId: clientID,
                                              clientSecret: nil,
                                              scopes: [OAuthTokenRequest.Scope.offlineAccess.rawValue, OIDScopeOpenID, OIDScopeEmail],
                                              redirectURL: authService.redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["audience": serverURL.absoluteString, "domain": domain])
        
        authorizationFlow = OIDAuthorizationService.present(request) { response, error in
            if let authError = error as NSError? {
                let oAuthError = OAuth2Error(error: authError)
                
                DispatchQueue.main.async {
                    completion(.failure(oAuthError))
                }
            } else if let authResponse = response,
                let authCode = authResponse.authorizationCode,
                let codeVerifier = request.codeVerifier {
                self.exchangeAuthorizationCode(code: authCode, codeVerifier: codeVerifier, completion: completion)
            }
        }
    }
    #endif
    
    /**
     Login a user using various authentication methods
     
     - parameters:
        - email: Email address of the user (optional)
        - password: Password for the user (optional)
        - completion: Completion handler with any error that occurred
     */
    public func loginUser(email: String, password: String, completion: @escaping FrolloSDKCompletionHandler) {
        guard !loggedIn
        else {
            let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .password,
                                        legacyToken: nil,
                                        password: password,
                                        redirectURI: nil,
                                        refreshToken: nil,
                                        username: email)
        
        // Authorize the user
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    self.networkAuthenticator.saveTokens(refresh: response.refreshToken, access: response.accessToken, expiry: expiryDate)
                    
                    self.loggedIn = true
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
            
        }
    }
    
    // MARK: - Tokens
    
    /**
     Exchange authorization code for a token
     
     Exchange an authorization code and code verifier for a token
     
     - parameters:
        - code: Authorization code
        - codeVerifier: Authorization code verifier for PKCE (Optional)
        - completion: Completion handler with any error that occurred
     */
    internal func exchangeAuthorizationCode(code: String, codeVerifier: String?, completion: @escaping FrolloSDKCompletionHandler) {
        guard !loggedIn
        else {
            let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(clientID: clientID,
                                        code: code,
                                        codeVerifier: codeVerifier,
                                        domain: domain,
                                        grantType: .authorizationCode,
                                        legacyToken: nil,
                                        password: nil,
                                        redirectURI: authService.redirectURL.absoluteString,
                                        refreshToken: nil,
                                        username: nil)
        
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    self.networkAuthenticator.saveTokens(refresh: response.refreshToken, access: response.accessToken, expiry: expiryDate)
                    
                    self.loggedIn = true
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    /**
     Exchange legacy access token
     
     Exchange a legacy access token if it exists for a new valid refresh access token pair.
     
     - parameters:
        - completion: Completion handler with any error that occurred
     */
    public func exchangeLegacyToken(completion: @escaping FrolloSDKCompletionHandler) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        guard let refreshToken = networkAuthenticator.refreshToken
        else {
            let error = DataError(type: .authentication, subType: .missingRefreshToken)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .password,
                                        legacyToken: refreshToken,
                                        password: nil,
                                        redirectURI: nil,
                                        refreshToken: nil,
                                        username: nil)
        
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    self.networkAuthenticator.clearTokens()
                    
                    Log.error(error.localizedDescription)
                    
                    completion(.failure(error))
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    self.networkAuthenticator.saveTokens(refresh: response.refreshToken, access: response.accessToken, expiry: expiryDate)
                    
                    completion(.success)
            }
        }
    }
    
    /**
     Refresh Access and Refresh Tokens
     
     Forces a refresh of the access and refresh tokens if a 401 was encountered. For advanced usage only in combination with web request authentication.
     
     - parameters:
        - completion: Completion handler with any error that occurred (Optional)
     */
    public func refreshTokens(completion: FrolloSDKCompletionHandler? = nil) {
        let request = OAuthTokenRequest(clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .refreshToken,
                                        legacyToken: nil,
                                        password: nil,
                                        redirectURI: nil,
                                        refreshToken: networkAuthenticator.refreshToken,
                                        username: nil)
        
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    self.networkAuthenticator.clearTokens()
                    
                    Log.error(error.localizedDescription)
                    
                    completion?(.failure(error))
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    self.networkAuthenticator.saveTokens(refresh: response.refreshToken, access: response.accessToken, expiry: expiryDate)
                    
                    completion?(.success)
            }
        }
    }
    
    // MARK: - Logout
    
    /**
     Logout the currently authenticated user from Frollo backend. Resets all caches and databases.
     
     - parameters:
        - completion: Completion handler with optional error if something goes wrong during the logout process
     */
    /**
     Log out the user from the server. This revokes the refresh token for the current device if not already revoked and resets the token storage.
     */
    public func logoutUser() {
        guard loggedIn
        else {
            Log.info("Cannot logout. User is not logged in.")
            
            return
        }
        
        reset()
    }
    
    // MARK: - Logout Handling
    
    internal func reset() {
        guard loggedIn else {
            Log.debug("Reset did nothing as user not logged in")
            
            return
        }
        
        loggedIn = false
        
        delegate?.authenticationReset()
    }
    
}
