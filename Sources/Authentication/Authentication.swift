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
    
}
