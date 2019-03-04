//
//  Authentication.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

#if os(iOS) && CORE
import AppAuthCore
#elseif os(tvOS)
import AppAUth
#else
import AppAuth
#endif

#if os(iOS) && !CORE
import SafariServices
import UIKit
#endif

internal protocol AuthenticationDelegate: class {
    
    func authenticationReset()
    
}

/**
 Authentication
 
 Manages authentication, login, registration, logout and the user profile.
 */
public class Authentication {
    
    internal struct AuthenticationNotification {
        static let userUpdated = Notification.Name("AuthenticationNotification.userUpdated")
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
    
    internal var authorizationFlow: OIDExternalUserAgentSession?
    
    private let authService: OAuthService
    private let clientID: String
    private let database: Database
    private let domain: String
    private let networkAuthenticator: NetworkAuthenticator
    private let preferences: Preferences
    private let service: APIService
    
    private weak var delegate: AuthenticationDelegate?
    
    init(database: Database, clientID: String, domain: String, networkAuthenticator: NetworkAuthenticator, authService: OAuthService, service: APIService, preferences: Preferences, delegate: AuthenticationDelegate?) {
        self.database = database
        self.clientID = clientID
        self.domain = domain
        self.networkAuthenticator = networkAuthenticator
        self.authService = authService
        self.service = service
        self.preferences = preferences
        self.delegate = delegate
        
        networkAuthenticator.authentication = self
        
        _ = fetchUser(context: database.viewContext)
    }
    
    // MARK: - Cache
    
    /**
     Fetch the first available user model from the cache
     
     - Returns: User object if found
    */
    public func fetchUser(context: NSManagedObjectContext) -> User? {
        var user: User?
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            
            do {
                let fetchedUsers = try context.fetch(fetchRequest)
                
                user = fetchedUsers.first
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return user
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
                                              scopes: [OAuthTokenRequest.Scope.offlineAccess.rawValue, OAuthTokenRequest.Scope.openID.rawValue],
                                              redirectURL: authService.redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["domain": domain])
        
        authorizationFlow = OIDAuthorizationService.present(request, presenting: presentingViewController) { response, error in
            if let authError = error as NSError? {
                let oAuthError = OAuthError(error: authError)
                
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
                                              scopes: [OAuthTokenRequest.Scope.offlineAccess.rawValue, OAuthTokenRequest.Scope.openID.rawValue],
                                              redirectURL: authService.redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["domain": domain])
        
        authorizationFlow = OIDAuthorizationService.present(request) { response, error in
            if let authError = error as NSError? {
                let oAuthError = OAuthError(error: authError)
                
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
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(audience: service.serverURL.absoluteString,
                                        clientID: clientID,
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
                    
                    // Fetch core details about the user. Fail and logout if we don't get necessary details
                    self.service.fetchUser { result in
                        switch result {
                            case .failure(let error):
                                self.loggedIn = false
                                
                                self.networkAuthenticator.clearTokens()
                                
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            case .success(let response):
                                self.handleUserResponse(userResponse: response)
                                
                                DispatchQueue.global(qos: .utility).async {
                                    self.updateDevice()
                                }
                                
                                DispatchQueue.main.async {
                                    completion(.success)
                                }
                        }
                    }
            }
            
        }
    }
    
    // MARK: - Register
    
    /**
     Register a user by email and password
     
     - parameters:
        - firstName: Given name of the user
        - lastName: Family name of the user, if provided (optional)
        - mobileNumber: Mobile phone number of the user, if provided (optional)
        - postcode: Postcode of the user, if provided (optional)
        - dateOfBirth: Date of birth of the user, if provided (optional)
        - email: Email address of the user
        - password: Password for the user
        - completion: Completion handler with any error that occurred
     */
    public func registerUser(firstName: String, lastName: String?, mobileNumber: String?, postcode: String?, dateOfBirth: Date?, email: String, password: String, completion: @escaping FrolloSDKCompletionHandler) {
        guard !loggedIn
        else {
            let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        var address: APIUserRegisterRequest.Address?
        if let registerPostcode = postcode {
            address = APIUserRegisterRequest.Address(postcode: registerPostcode)
        }
        
        let userRegisterRequest = APIUserRegisterRequest(email: email,
                                                         firstName: firstName,
                                                         password: password,
                                                         address: address,
                                                         dateOfBirth: dateOfBirth,
                                                         lastName: lastName,
                                                         mobileNumber: mobileNumber)
        
        // Create the user on the server and at the authorization endpoint
        service.registerUser(request: userRegisterRequest) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let userResponse):
                    // Authenticate the user at the token endpoint after creation
                    let tokenRequest = OAuthTokenRequest(audience: self.service.serverURL.absoluteString,
                                                         clientID: self.clientID,
                                                         code: nil,
                                                         codeVerifier: nil,
                                                         domain: self.domain,
                                                         grantType: .password,
                                                         legacyToken: nil,
                                                         password: password,
                                                         redirectURI: nil,
                                                         refreshToken: nil,
                                                         username: email)
                    
                    self.authService.refreshTokens(request: tokenRequest) { result in
                        switch result {
                            case .failure(let error):
                                self.loggedIn = false
                                
                                self.networkAuthenticator.clearTokens()
                                
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            case .success(let response):
                                let createdDate = response.createdAt ?? Date()
                                let expiryDate = createdDate.addingTimeInterval(response.expiresIn)
                                
                                self.networkAuthenticator.saveTokens(refresh: response.refreshToken, access: response.accessToken, expiry: expiryDate)
                                
                                self.handleUserResponse(userResponse: userResponse)
                                
                                self.loggedIn = true
                                
                                DispatchQueue.global(qos: .utility).async {
                                    self.updateDevice()
                                }
                                
                                DispatchQueue.main.async {
                                    completion(.success)
                                }
                        }
                    }
            }
        }
    }
    
    // MARK: - Forgot Password
    
    /**
     Reset the password for the specified email. Sends an email to the address provided if an account exists with instructions on resetting the password.
     
     - parameters:
        - email: Email address of the account to begin resetting the password for.
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process.
     */
    public func resetPassword(email: String, completion: @escaping FrolloSDKCompletionHandler) {
        let request = APIUserResetPasswordRequest(email: email)
        
        service.resetPassword(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    // MARK: - User
    
    /**
     Refresh the user details
     
     Refreshes the latest details of the user from the server. This should be called on app launch and resuming after a set period of time if the user is already logged in. This returns the same data as login and register.
     
     - parameters:
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process. (Optional)
     */
    public func refreshUser(completion: FrolloSDKCompletionHandler? = nil) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.fetchUser { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    self.handleUserResponse(userResponse: response)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update the user details
     
     Updates the user details from cache on the server. This should be called whenever details or statistics about a user are altered, e.g. changing email.
     
     - parameters:
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process.
     */
    public func updateUser(completion: @escaping FrolloSDKCompletionHandler) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        guard let user = fetchUser(context: managedObjectContext)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        var request: APIUserUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = user.updateRequest()
        }
        
        service.updateUser(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    self.handleUserResponse(userResponse: response)
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    /**
     Change the password for the user. Current password is not needed for users who signed up using a 3rd party and never set a password. Check for `validPassword` on the user profile to determine this.
     
     - parameters:
        - currentPassword: Current password to validate the user (optional)
        - newPassword: New password for the user - must be at least 8 characters
        - completion: Completion handler with any error that occurred
     */
    internal func changePassword(currentPassword: String?, newPassword: String, completion: @escaping FrolloSDKCompletionHandler) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let changePasswordRequest = APIUserChangePasswordRequest(currentPassword: currentPassword,
                                                                 newPassword: newPassword)
        
        guard changePasswordRequest.valid()
        else {
            let error = DataError(type: .api, subType: .passwordTooShort)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        service.changePassword(request: changePasswordRequest) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    /**
     Delete the user account and complete logout activities on success
     
     - parameters:
        - completion: Completion handler with any error that occurred
    */
    public func deleteUser(completion: @escaping FrolloSDKCompletionHandler) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        service.deleteUser { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success:
                    self.reset()
                    
                    self.delegate?.authenticationReset()
                    
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
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(audience: service.serverURL.absoluteString,
                                        clientID: clientID,
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
                    
                    // Fetch core details about the user. Fail and logout if we don't get necessary details
                    self.service.fetchUser { result in
                        switch result {
                            case .failure(let error):
                                self.loggedIn = false
                                
                                self.networkAuthenticator.clearTokens()
                                
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            case .success(let response):
                                self.handleUserResponse(userResponse: response)
                                
                                DispatchQueue.global(qos: .utility).async {
                                    self.updateDevice()
                                }
                                
                                DispatchQueue.main.async {
                                    completion(.success)
                                }
                        }
                    }
            }
        }
    }
    
    /**
     Exchange legacy access token
     
     Exchange a legacy access token for a new valid refresh access token pair.
     
     - parameters:
        - legacyToken: Legacy access token to be exchanged
        - completion: Completion handler with any error that occurred
    */
    public func exchangeLegacyToken(legacyToken: String, completion: @escaping FrolloSDKCompletionHandler) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let request = OAuthTokenRequest(audience: service.serverURL.absoluteString,
                                        clientID: clientID,
                                        code: nil,
                                        codeVerifier: nil,
                                        domain: domain,
                                        grantType: .password,
                                        legacyToken: legacyToken,
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
        service.network.authenticator.refreshTokens()
        
        let request = OAuthTokenRequest(audience: service.serverURL.absoluteString,
                                        clientID: clientID,
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
    
    // MARK: - Web Request Authentication
    
    /**
     Authenticate a web request
     
     Allows authenticating a `URLRequest` manually with the user's current access token. For advanced usage such as authenticating calls to web content.
     
     - parameters:
        - request: URL Request to be authenticated and provided the access token
    */
    public func authenticateRequest(_ request: URLRequest) throws -> URLRequest {
        return try service.network.authenticator.validateAndAppendAccessToken(request: request)
    }
    
    // MARK: - Device
    
    /**
     Update the compliance status of the current device. Use this to indicate a jailbroken device for example.
     
     - parameters:
        - compliant: Indicates if the device is compliant or not
        - completion: Completion handler with any error that occurred (optional)
    */
    public func updateDeviceCompliance(_ compliant: Bool, completion: FrolloSDKCompletionHandler? = nil) {
        updateDevice(compliant: compliant, notificationToken: nil, completion: completion)
    }
    
    /**
     Update information about the current device. Updates the current device name and timezone automatically.
     
     - parameters:
        - compliant: Indicates if the device is compliant or not
        - notificationToken: Push notification token for the device (optional)
        - completion: Completion handler with any error that occurred (optional)
     */
    internal func updateDevice(compliant: Bool? = nil, notificationToken: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        guard loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        let deviceInfo = DeviceInfo.current()
        
        let request = APIDeviceUpdateRequest(compliant: compliant,
                                             deviceID: deviceInfo.deviceID,
                                             deviceName: deviceInfo.deviceName,
                                             deviceType: deviceInfo.deviceType,
                                             notificationToken: notificationToken,
                                             timezone: TimeZone.current.identifier)
        
        service.updateDevice(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
            return
        }
        
        service.logoutUser { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reset()
        
        delegate?.authenticationReset()
    }
    
    // MARK: - User Model
    
    private func handleUserResponse(userResponse: APIUserResponse) {
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            
            do {
                let fetchedUsers = try managedObjectContext.fetch(fetchRequest)
                
                let user: User
                if let fetchedUser = fetchedUsers.first {
                    user = fetchedUser
                } else {
                    user = User(context: managedObjectContext)
                }
                
                loggedIn = true
                
                user.update(response: userResponse)
                
                preferences.refreshFeatures(user: user)
                
                do {
                    try managedObjectContext.save()
                } catch {
                    Log.error(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: AuthenticationNotification.userUpdated, object: user)
                }
            } catch let error as NSError {
                Log.error(error.localizedDescription)
                
                if error.domain == NSCocoaErrorDomain, error.code == 256, let sqliteError = error.userInfo[NSSQLiteErrorDomain] as? NSNumber, sqliteError.int32Value == 1 {
                    Log.error("Critical database error, corrupted.")
                }
            }
        }
    }
    
    // MARK: - Logout Handling
    
    internal func reset() {
        guard loggedIn else {
            return
        }
        
        loggedIn = false
        
        service.network.reset()
    }
    
}
