//
//  Authentication.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

public struct FrolloSDKAuthenticationNotification {
    public static let authenticationStatusChanged = "FrolloSDKAuthenticationNotification.authenticationStatusChanged"
}

/**
 Authentication
 
 Manages authentication, login, registration, logout and the user profile.
 */
class Authentication {
    
    struct AuthenticationNotification {
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
    
    // MARK: - Login, Register and User Profile
    
    /**
     Change the password for the user. Current password is not needed for users who signed up using a 3rd party and never set a password. Check for `validPassword` on the user profile to determine this.
     
     - parameters:
        - currentPassword: Current password to validate the user (optional)
        - newPassword: New password for the user - must be at least 8 characters
    */
    internal func changePassword(currentPassword: String?, newPassword: String, completion: @escaping FrolloSDKCompletionHandler) {
        let changePasswordRequest = APIUserChangePasswordRequest(currentPassword: currentPassword,
                                                                 newPassword: newPassword)
        
        guard changePasswordRequest.valid()
            else {
                let error = DataError(type: .api, subType: .passwordTooShort)
                    
                completion(error)
                return
        }
        
        network.changePassword(request: changePasswordRequest) { (data, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            }
            
            completion(error)
        }
    }
    
    /**
     Login a user using various authentication methods
     
     - parameters:
         - method: Login method to be used. See AuthType for details
         - email: Email address of the user (optional)
         - password: Password for the user (optional)
         - userID: Unique identifier for the user depending on authentication method (optional)
         - userToken: Token for the user depending on authentication method (optional)
         - completion: Completion handler with any error that occurred
    */
    internal func loginUser(method: APIUserLoginRequest.AuthType, email: String? = nil, password: String? = nil, userID: String? = nil, userToken: String? = nil, completion: @escaping FrolloSDKCompletionHandler) {
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
            
            completion(error)
        }
    }
    
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
    
    /**
     Register a user by email and password
     
     - parameters:
        - firstName: Given name of the user
        - lastName: Family name of the user, if provided (optional)
        - email: Email address of the user
        - password: Password for the user
        - completion: Completion handler with any error that occurred
     */
    internal func registerUser(firstName: String, lastName: String?, email: String, password: String, completion: @escaping FrolloSDKCompletionHandler) {
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
            
            completion(error)
        }
    }
    
    /**
     Refresh the user details
     
     Refreshes the latest details of the user from the server. This should be called on app launch and resuming after a set period of time if the user is already logged in. This returns the same data as login and register.
     
     - parameters:
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process.
    */
    public func refreshUser(completion: @escaping FrolloSDKCompletionHandler) {
        network.fetchUser { (data, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let userResponse = data {
                    self.handleUserResponse(userResponse: userResponse)
                }
            }
            
            completion(error)
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
                
                completion(error)
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
            
            completion(error)
        }
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
