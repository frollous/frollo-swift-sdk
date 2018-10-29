//
//  Authentication.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

/// Frollo SDK authentication notifications
public struct FrolloSDKAuthenticationNotification {
    
    /// Notification indicating the user authentication status has changed
    public static let authenticationStatusChanged = "FrolloSDKAuthenticationNotification.authenticationStatusChanged"
    
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
        /**
         Email
         
         Authenticate with an email address and password
         */
        case email
        
        /**
         Facebook
         
         Authenticate using Facebook using the user's email, Facebook User ID and Facebook Access Token.
         */
        case facebook
        
        /**
         Volt
         
         Authenticate using a Volt token, requires email, Volt user ID and Volt access token.
         */
        case volt
    }
    
    internal struct AuthenticationNotification {
        static let userUpdated = Notification.Name("AuthenticationNotification.userUpdated")
    }
    
    /**
     Indicates if the user is currently authorised with Frollo
    */
    public var loggedIn: Bool {
        get {
            return preferences.loggedIn
        }
        set {
            preferences.loggedIn = newValue
        }
    }
    
    /**
     User model from cache if available
    */
    public var user: User? {
        get {
            return fetchUser()
        }
    }
    
    private let database: Database
    private let network: Network
    private let preferences: Preferences
    
    init(database: Database, network: Network, preferences: Preferences) {
        self.database = database
        self.network = network
        self.preferences = preferences
    }
    
    internal func authenticate(_ authToken: String, completion: FrolloSDKCompletionHandler) {
        completion(nil)
    }
    
    // MARK: - Cache
    
    /**
     Fetch the first available user model from the cache
    */
    private func fetchUser() -> User? {
        var fetchedUser: User?
        
        let managedObjectContext = database.viewContext
        
        managedObjectContext.performAndWait {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            
            do {
                let fetchedUsers = try managedObjectContext.fetch(fetchRequest)
                
                fetchedUser = fetchedUsers.first
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return fetchedUser
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
        let deviceInfo = DeviceInfo.current()
        
        let userLoginRequest = APIUserLoginRequest(authType: method,
                                                   deviceID: deviceInfo.deviceID,
                                                   deviceName: deviceInfo.deviceName,
                                                   deviceType: deviceInfo.deviceType,
                                                   email: email,
                                                   password: password,
                                                   userID: userID,
                                                   userToken: userToken)
        
        network.loginUser(request: userLoginRequest) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let userResponse = response {
                    self.handleUserResponse(userResponse: userResponse)
                }
            }
            
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    // MARK: - Register
    
    /**
     Register a user by email and password
     
     - parameters:
        - firstName: Given name of the user
        - lastName: Family name of the user, if provided (optional)
        - email: Email address of the user
        - password: Password for the user
        - completion: Completion handler with any error that occurred
     */
    public func registerUser(firstName: String, lastName: String?, email: String, password: String, completion: @escaping FrolloSDKCompletionHandler) {
        let deviceInfo = DeviceInfo.current()
        
        let userRegisterRequest = APIUserRegisterRequest(deviceID: deviceInfo.deviceID,
                                                         deviceName: deviceInfo.deviceName,
                                                         deviceType: deviceInfo.deviceType,
                                                         email: email,
                                                         firstName: firstName,
                                                         password: password,
                                                         lastName: lastName)
        
        network.registerUser(request: userRegisterRequest) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let userResponse = response {
                    self.handleUserResponse(userResponse: userResponse)
                }
            }
            
            DispatchQueue.main.async {
                completion(error)
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
        
        network.resetPassword(request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion(error)
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
        network.fetchUser { (data, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let userResponse = data {
                    self.handleUserResponse(userResponse: userResponse)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
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
        guard let request = user?.updateRequest()
            else {
                let error = DataError(type: .database, subType: .notFound)
                
                DispatchQueue.main.async {
                    completion(error)
                }
                return
        }
        
        network.updateUser(request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let userResponse = response {
                    self.handleUserResponse(userResponse: userResponse)
                }
            }
            
            DispatchQueue.main.async {
                completion(error)
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
        let changePasswordRequest = APIUserChangePasswordRequest(currentPassword: currentPassword,
                                                                 newPassword: newPassword)
        
        guard changePasswordRequest.valid()
            else {
                let error = DataError(type: .api, subType: .passwordTooShort)
                
                DispatchQueue.main.async {
                    completion(error)
                }
                return
        }
        
        network.changePassword(request: changePasswordRequest) { (data, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /**
     Delete the user account and complete logout activities on success
     
     - parameters:
        - completion: Completion handler with any error that occurred
    */
    public func deleteUser(completion: @escaping FrolloSDKCompletionHandler) {
        network.deleteUser { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                self.reset()
            }
            
            DispatchQueue.main.async {
                completion(error)
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
    internal func logoutUser() {
        network.logoutUser { (data, error) in
            if let logoutError = error {
                Log.error(logoutError.localizedDescription)
            }
        }
        
        reset()
    }
    
    // MARK: - User Model
    
    private func handleUserResponse(userResponse: APIUserResponse) {
        let managedObjectContext = self.database.newBackgroundContext()
        
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
            
            NotificationCenter.default.post(name: AuthenticationNotification.userUpdated, object: user)
        } catch {
            Log.error(error.localizedDescription)
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
