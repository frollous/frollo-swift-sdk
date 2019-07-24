//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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

/**
 Authentication
 
 Manages authentication, login, registration, logout and the user profile.
 */
public class OAuth2Authentication: Authentication {
    
    internal struct KeychainKey {
        static let refreshToken = "refreshToken"
    }
    
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
    
    /**
     SDK delegate to be called to update SDK about authentication events. SDK sets this as part of setup
     */
    public weak var delegate: AuthenticationDelegate?
    
    /**
     SDK delegate to be called to update SDK about token update events. SDK sets this as part of setup
     */
    public weak var tokenDelegate: AuthenticationTokenDelegate?
    
    internal var authorizationFlow: OIDExternalUserAgentSession?
    internal var refreshToken: String?
    
    private let authService: OAuthService
    private let clientID: String
    private let domain: String
    private let keychain: Keychain
    private let preferences: Preferences
    private let redirectURL: URL
    private let serverURL: URL
    
    init(keychain: Keychain, clientID: String, redirectURL: URL, serverURL: URL, authService: OAuthService, preferences: Preferences, delegate: AuthenticationDelegate?, tokenDelegate: AuthenticationTokenDelegate?) {
        self.keychain = keychain
        self.clientID = clientID
        self.domain = serverURL.host ?? serverURL.absoluteString
        self.authService = authService
        self.preferences = preferences
        self.redirectURL = redirectURL
        self.serverURL = serverURL
        self.delegate = delegate
        self.tokenDelegate = tokenDelegate
        
        loadTokens()
    }
    
    // MARK: - Login
    
    #if os(iOS) && !CORE
    /**
     Login a user via web view
     
     Initiate the authorization code login flow using a web view
     
     - parameters:
        - presentingViewController: View controller the Safari Web ViewController should be presented from
        - additionalParameters: Pass additional query parameters to the authorization endpoint (Optional)
        - completion: Completion handler with any error that occurred
     */
    public func loginUserUsingWeb(presenting presentingViewController: UIViewController, scopes: [String], additionalParameters: [String: String]? = nil, completion: @escaping FrolloSDKCompletionHandler) {
        let config = OIDServiceConfiguration(authorizationEndpoint: authService.authorizationURL, tokenEndpoint: authService.tokenURL)
        
        var parameters = ["audience": serverURL.absoluteString, "domain": domain]
        additionalParameters?.forEach { k, v in parameters[k] = v }
        
        let request = OIDAuthorizationRequest(configuration: config,
                                              clientId: clientID,
                                              clientSecret: nil,
                                              scopes: scopes,
                                              redirectURL: authService.redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: parameters)
        
        authorizationFlow = OIDAuthorizationService.present(request, presenting: presentingViewController) { response, error in
            if let authError = error as NSError? {
                let oAuthError = OAuth2Error(error: authError)
                
                self.handleTokenError(error: oAuthError)
                
                DispatchQueue.main.async {
                    completion(.failure(oAuthError))
                }
            } else if let authResponse = response,
                let authCode = authResponse.authorizationCode,
                let codeVerifier = request.codeVerifier {
                self.exchangeAuthorizationCode(code: authCode, codeVerifier: codeVerifier, scopes: scopes, completion: completion)
            }
        }
    }
    #endif
    
    #if os(macOS)
    /**
     Login a user via web view
     
     Initiate the authorization code login flow using a web view
     
     - parameters:
        - additionalParameters: Pass additional query parameters to the authorization endpoint (Optional)
        - completion: Completion handler with any error that occurred
     */
    public func loginUserUsingWeb(scopes: [String], additionalParameters: [String: String]? = nil, completion: @escaping FrolloSDKCompletionHandler) {
        let config = OIDServiceConfiguration(authorizationEndpoint: authService.authorizationURL, tokenEndpoint: authService.tokenURL)
        
        var parameters = ["audience": serverURL.absoluteString, "domain": domain]
        additionalParameters?.forEach { k, v in parameters[k] = v }
        
        let request = OIDAuthorizationRequest(configuration: config,
                                              clientId: clientID,
                                              clientSecret: nil,
                                              scopes: scopes,
                                              redirectURL: authService.redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: parameters)
        
        authorizationFlow = OIDAuthorizationService.present(request) { response, error in
            if let authError = error as NSError? {
                let oAuthError = OAuth2Error(error: authError)
                
                self.handleTokenError(error: oAuthError)
                
                DispatchQueue.main.async {
                    completion(.failure(oAuthError))
                }
            } else if let authResponse = response,
                let authCode = authResponse.authorizationCode,
                let codeVerifier = request.codeVerifier {
                self.exchangeAuthorizationCode(code: authCode, codeVerifier: codeVerifier, scopes: ["offline_access", "email", "openid"], completion: completion)
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
    public func loginUser(email: String, password: String, scopes: [String], completion: @escaping FrolloSDKCompletionHandler) {
        guard !loggedIn
        else {
            let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(audience: serverURL.absoluteString,
                                        clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .password,
                                        legacyToken: nil,
                                        password: password,
                                        redirectURI: nil,
                                        refreshToken: nil,
                                        scope: scopes.joined(separator: " "),
                                        username: email)
        
        // Authorize the user
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    self.handleTokenError(error: error)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    if let refreshToken = response.refreshToken {
                        self.updateToken(refreshToken)
                    }
                    
                    self.tokenDelegate?.saveAccessTokens(accessToken: response.accessToken, expiry: expiryDate)
                    
                    self.loggedIn = true
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
            
        }
    }
    
    public func resumeAuthentication(url: URL) -> Bool {
        if url.scheme == redirectURL.scheme,
            url.user == redirectURL.user,
            url.password == redirectURL.password,
            url.host == redirectURL.host,
            url.port == redirectURL.port,
            url.path == redirectURL.path {
            authorizationFlow?.resumeExternalUserAgentFlow(with: url)
            
            return true
        }
        
        return false
    }
    
    // MARK: - Tokens
    
    /**
     Exchange authorization code for a token
     
     Exchange an authorization code and code verifier for a token
     
     - parameters:
        - code: Authorization code
        - codeVerifier: Authorization code verifier for PKCE (Optional)
        - scopes: OpenID Connect OAuth2 scopes
        - completion: Completion handler with any error that occurred
     */
    internal func exchangeAuthorizationCode(code: String, codeVerifier: String?, scopes: [String], completion: @escaping FrolloSDKCompletionHandler) {
        guard !loggedIn
        else {
            let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(audience: serverURL.absoluteString,
                                        clientID: clientID,
                                        code: code,
                                        codeVerifier: codeVerifier,
                                        domain: domain,
                                        grantType: .authorizationCode,
                                        legacyToken: nil,
                                        password: nil,
                                        redirectURI: authService.redirectURL.absoluteString,
                                        refreshToken: nil,
                                        scope: scopes.joined(separator: " "),
                                        username: nil)
        
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    self.handleTokenError(error: error)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    if let refreshToken = response.refreshToken {
                        self.updateToken(refreshToken)
                    }
                    
                    self.tokenDelegate?.saveAccessTokens(accessToken: response.accessToken, expiry: expiryDate)
                    
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
        
        guard let token = refreshToken
        else {
            let error = DataError(type: .authentication, subType: .missingRefreshToken)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let scopes = [OAuthTokenRequest.Scope.offlineAccess.rawValue, OIDScopeOpenID, OIDScopeEmail].joined(separator: " ")
        
        let request = OAuthTokenRequest(audience: serverURL.absoluteString,
                                        clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .password,
                                        legacyToken: token,
                                        password: nil,
                                        redirectURI: nil,
                                        refreshToken: nil,
                                        scope: scopes,
                                        username: nil)
        
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    self.handleTokenError(error: error)
                    
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    if let refreshToken = response.refreshToken {
                        self.updateToken(refreshToken)
                    }
                    
                    self.tokenDelegate?.saveAccessTokens(accessToken: response.accessToken, expiry: expiryDate)
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    /**
     Refresh Access and Refresh Tokens
     
     Forces a refresh of the access and refresh tokens if a 401 was encountered. For advanced usage only in combination with web request authentication.
     
     - parameters:
        - completion: Completion handler with tokens if successful or any error that occurred
     */
    public func refreshTokens(completion: FrolloSDKCompletionHandler?) {
        guard let token = refreshToken
        else {
            let error = DataError(type: .authentication, subType: .missingRefreshToken)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(audience: nil,
                                        clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .refreshToken,
                                        legacyToken: nil,
                                        password: nil,
                                        redirectURI: nil,
                                        refreshToken: token,
                                        scope: nil,
                                        username: nil)
        
        authService.refreshTokens(request: request) { result in
            switch result {
                case .failure(let error):
                    self.handleTokenError(error: error)
                    
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let createdDate = response.createdAt ?? Date()
                    let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                    
                    if let refreshToken = response.refreshToken {
                        self.updateToken(refreshToken)
                    }
                    
                    self.tokenDelegate?.saveAccessTokens(accessToken: response.accessToken, expiry: expiryDate)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Logout
    
    /**
     Logout user
     
     Logout the user by revoking the refresh token if possible followed by local cleanup by calling reset
     */
    public func logout() {
        // Revoke the refresh token if possible
        if let token = refreshToken {
            let request = OAuthTokenRevokeRequest(clientID: clientID, token: token)
            
            authService.revokeToken(request: request) { result in
                switch result {
                    case .failure(let error):
                        Log.error(error.localizedDescription)
                    case .success:
                        break
                }
            }
        }
        
        reset()
    }
    
    /**
     Reset the authentication state. Resets the user to a logged out state and clears any tokens cached
     */
    public func reset() {
        loggedIn = false
        
        clearTokens()
        
        delegate?.authenticationReset()
    }
    
    // MARK: - Token Handling
    
    internal func handleTokenError(error: Error) {
        if let authError = error as? OAuth2Error {
            let clearTokenStatuses: [OAuth2Error.OAuth2ErrorType] = [.invalidClient, .invalidRequest, .invalidGrant, .invalidScope, .unauthorizedClient, .unsupportedGrantType, .serverError]
            
            if clearTokenStatuses.contains(authError.type) {
                reset()
            }
        } else if let dataError = error as? DataError {
            let clearTokenStatuses: [DataError.DataErrorType] = [.authentication]
            
            if clearTokenStatuses.contains(dataError.type) {
                reset()
            }
        }
    }
    
    internal func updateToken(_ token: String) {
        refreshToken = token
        
        keychain[KeychainKey.refreshToken] = token
    }
    
    internal func clearTokens() {
        refreshToken = nil
        
        keychain[KeychainKey.refreshToken] = nil
    }
    
    private func loadTokens() {
        refreshToken = keychain[KeychainKey.refreshToken]
    }
    
}
