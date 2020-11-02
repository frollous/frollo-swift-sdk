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

import CoreData
import Foundation

internal protocol UserManagementDelegate: AnyObject {
    
    func userDeleted()
    
}

/**
 User Management
 
 Manages the user details and device
 */
public class UserManagement {
    
    internal struct UserNotification {
        static let userUpdated = Notification.Name("UserNotification.userUpdated")
    }
    
    private let authentication: OAuth2Authentication?
    private let clientID: String
    private let database: Database
    private let preferences: Preferences
    private let service: APIService
    
    private weak var delegate: UserManagementDelegate?
    
    init(database: Database, service: APIService, clientID: String, authentication: OAuth2Authentication?, preferences: Preferences, delegate: UserManagementDelegate?) {
        self.authentication = authentication
        self.database = database
        self.service = service
        self.clientID = clientID
        self.preferences = preferences
        self.delegate = delegate
        
        _ = fetchUser(context: database.viewContext)
    }
    
    // MARK: - User
    
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
    
    /**
     Refresh the user details
     
     Refreshes the latest details of the user from the server. This should be called on app launch and resuming after a set period of time if the user is already logged in. This returns the same data as login and register.
     
     - parameters:
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process. (Optional)
     */
    public func refreshUser(completion: FrolloSDKCompletionHandler? = nil) {
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
        var address: APIUserRegisterRequest.Address?
        if let registerPostcode = postcode {
            address = APIUserRegisterRequest.Address(postcode: registerPostcode)
        }
        
        let userRegisterRequest = APIUserRegisterRequest(clientID: clientID,
                                                         email: email,
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
                    self.handleUserResponse(userResponse: userResponse)
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    /**
     Update the user details
     
     Updates the user details from cache on the server. This should be called whenever details or statistics about a user are altered, e.g. changing email.
     
     - parameters:
        - securityCode: Verification code/ OTP for updtaing sensitive information
        - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process.
     */
    public func updateUser(securityCode: String? = nil, completion: @escaping FrolloSDKCompletionHandler) {
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
        
        service.updateUser(request: request, otpCode: securityCode) { result in
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
     Delete the user account and complete logout activities on success
     
     - parameters:
     - completion: Completion handler with any error that occurred
     */
    public func deleteUser(completion: @escaping FrolloSDKCompletionHandler) {
        service.deleteUser { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success:
                    self.delegate?.userDeleted()
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    /**
     Migrate user
     
     Migrates a user from one identity provider to another if available. The user will then be logged out
     and need to be authenticated again.
     
     - parameters:
     - password: The new password for the migrated user
     - completion: Completion handler with any error that occurred
     */
    public func migrateUser(password: String, completion: @escaping FrolloSDKCompletionHandler) {
        guard let refreshToken = authentication?.refreshToken
        else {
            let error = DataError(type: .authentication, subType: .missingRefreshToken)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let migrationRequest = APIUserMigrationRequest(password: password)
        
        guard migrationRequest.valid()
        else {
            let error = DataError(type: .api, subType: .passwordTooShort)
            
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        service.migrateUser(request: migrationRequest, token: refreshToken) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success:
                    self.delegate?.userDeleted()
                    
                    DispatchQueue.main.async {
                        completion(.success)
                    }
            }
        }
    }
    
    // MARK: - Password
    
    /**
     Change the password for the user. Current password is not needed for users who signed up using a 3rd party and never set a password. Check for `validPassword` on the user profile to determine this.
     
     - parameters:
     - currentPassword: Current password to validate the user (optional)
     - newPassword: New password for the user - must be at least 8 characters
     - completion: Completion handler with any error that occurred
     */
    public func changePassword(currentPassword: String?, newPassword: String, completion: @escaping FrolloSDKCompletionHandler) {
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
     Reset the password for the specified email. Sends an email to the address provided if an account exists with instructions on resetting the password.
     
     - parameters:
     - email: Email address of the account to begin resetting the password for.
     - completion: A completion handler once the API has returned and the cache has been updated. Returns any error that occurred during the process.
     */
    public func resetPassword(email: String, completion: @escaping FrolloSDKCompletionHandler) {
        let request = APIUserResetPasswordRequest(clientID: clientID,
                                                  email: email)
        
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
    public func updateDevice(compliant: Bool? = nil, notificationToken: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
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
    
    // MARK: - Response Handling
    
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
                
                user.update(response: userResponse)
                
                preferences.refreshFeatures(user: user)
                
                do {
                    try managedObjectContext.save()
                } catch {
                    Log.error(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: UserNotification.userUpdated, object: user)
                }
            } catch let error as NSError {
                Log.error(error.localizedDescription)
                
                if error.domain == NSCocoaErrorDomain, error.code == 256, let sqliteError = error.userInfo[NSSQLiteErrorDomain] as? NSNumber, sqliteError.int32Value == 1 {
                    Log.error("Critical database error, corrupted.")
                }
            }
        }
    }
    
    /**
     Request new OTP for the user.
     
     - parameters:
     - method: Method by which the otp will be sent to the user. eg. sms
     - completion: Completion handler with any error that occurred
     */
    public func requestNewOTPCodeForUser(method: User.OtpMethodType = .sms, completion: @escaping FrolloSDKCompletionHandler) {
        let sendOTPRequest = APIUserOTPRequest(method: method)
        
        service.sendOTP(request: sendOTPRequest) { result in
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
     Fetch all the unconfirmed user details
     
     - parameters:
     - completion: Completion handler with any error that occurred
     */
    public func fetchUnconfimedUserDetails(completion: @escaping (Result<APIUserDetailsConfirm, Error>) -> Void) {
        
        service.fetchUnconfirmedUserDetails { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     Fetch all the unconfirmed user details
     
     - parameters:
     - mobileNumber: Mobile number to be confirmed/ verified
     - securityCode: Verification code/ OTP for confirming sensitive information
     - completion: Completion handler with any error that occurred
     */
    public func confimUserDetails(mobileNumber: String, securityCode: String? = nil, completion: @escaping FrolloSDKCompletionHandler) {
        
        let confirmDetailsRequest = APIUserDetailsConfirm(mobileNumber: mobileNumber)
        
        service.confirmUserDetails(request: confirmDetailsRequest, otpCode: securityCode) { result in
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
    
}
