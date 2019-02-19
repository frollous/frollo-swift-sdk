//
//  Authentication.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

#if os(macOS)
import AppAuth
#elseif os(iOS)
import AppAuthCore
#elseif os(tvOS)
import AppAUth
#elseif os(watchOS)
import AppAuth
#endif

internal protocol AuthenticationDelegate: class {
    
    func authenticationReset()
    
}

/**
 Authentication
 
 Manages authentication, login, registration, logout and the user profile.
 */
public class Authentication {
    
    /**
     Authentication Type
     
     The method to be used for authenticating the user when logging in.
     */
    public enum AuthType: String, Codable {
        /// Authenticate with an email address and password
        case email
        
        /// Authenticate using Facebook using the user's email, Facebook User ID and Facebook Access Token.
        case facebook
        
        /// Authenticate using a Volt token, requires email, Volt user ID and Volt access token.
        case volt
    }
    
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
    
    private let database: Database
    private let network: Network
    private let preferences: Preferences
    
    private weak var delegate: AuthenticationDelegate?
    
    init(database: Database, network: Network, preferences: Preferences, delegate: AuthenticationDelegate?) {
        self.database = database
        self.network = network
        self.preferences = preferences
        self.delegate = delegate
        
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
    
    /**
     Login a user using various authentication methods
     
     - parameters:
        - method: Login method to be used. See `AuthType` for details
        - email: Email address of the user (optional)
        - password: Password for the user (optional)
        - userID: Unique identifier for the user depending on authentication method (optional)
        - userToken: Token for the user depending on authentication method (optional)
        - completion: Completion handler with any error that occurred
     */
    public func loginUser(method: AuthType, email: String? = nil, password: String? = nil, userID: String? = nil, userToken: String? = nil, completion: @escaping FrolloSDKCompletionHandler) {
        guard !loggedIn
            else {
                let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
        }
        
        let deviceInfo = DeviceInfo.current()
        
        let userLoginRequest = APIUserLoginRequest(authType: method,
                                                   deviceID: deviceInfo.deviceID,
                                                   deviceName: deviceInfo.deviceName,
                                                   deviceType: deviceInfo.deviceType,
                                                   email: email,
                                                   password: password,
                                                   userID: userID,
                                                   userToken: userToken)
        
        network.loginUser(request: userLoginRequest) { (result) in
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
        
        let deviceInfo = DeviceInfo.current()
        
        var address: APIUserRegisterRequest.Address?
        if let registerPostcode = postcode {
            address = APIUserRegisterRequest.Address(postcode: registerPostcode)
        }
        
        let userRegisterRequest = APIUserRegisterRequest(deviceID: deviceInfo.deviceID,
                                                         deviceName: deviceInfo.deviceName,
                                                         deviceType: deviceInfo.deviceType,
                                                         email: email,
                                                         firstName: firstName,
                                                         password: password,
                                                         address: address,
                                                         dateOfBirth: dateOfBirth,
                                                         lastName: lastName,
                                                         mobileNumber: mobileNumber)
        
        network.registerUser(request: userRegisterRequest) { (result) in
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
    
    // MARK: - Forgot Password
    
    /**
     Reset the password for the specified email. Sends an email to the address provided if an account exists with instructions on resetting the password.
     
     - parameters:
        - email: Email address of the account to begin resetting the password for.
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process.
     */
    public func resetPassword(email: String, completion: @escaping FrolloSDKCompletionHandler) {
        let request = APIUserResetPasswordRequest(email: email)
        
        network.resetPassword(request: request) { (result) in
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
        
        network.fetchUser { (result) in
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
        
        network.updateUser(request: request) { (result) in
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
        
        network.changePassword(request: changePasswordRequest) { (result) in
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
        
        network.deleteUser { (result) in
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
    
    /**
     Refresh Access and Refresh Tokens
     
     Forces a refresh of the access and refresh tokens if a 401 was encountered. For advanced usage only in combination with web request authentication.
    */
    public func refreshTokens() {
        network.authenticator.refreshTokens()
    }
    
    // MARK: - Web Request Authentication
    
    /**
     Authenticate a web request
     
     Allows authenticating a `URLRequest` manually with the user's current access token. For advanced usage such as authenticating calls to web content.
     
     - parameters:
        - request: URL Request to be authenticated and provided the access token
    */
    public func authenticateRequest(_ request: URLRequest) throws -> URLRequest {
        return try network.authenticator.validateAndAppendAccessToken(request: request)
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
                                             deviceName: deviceInfo.deviceName,
                                             notificationToken: notificationToken,
                                             timezone: TimeZone.current.identifier)
        
        network.updateDevice(request: request) { (result) in
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
        
        network.logoutUser { (result) in
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
        let managedObjectContext = self.database.newBackgroundContext()
        
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
                
                if error.domain == NSCocoaErrorDomain && error.code == 256, let sqliteError = error.userInfo[NSSQLiteErrorDomain] as? NSNumber, sqliteError.int32Value == 1 {
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
        
        network.reset()
    }
    
}
