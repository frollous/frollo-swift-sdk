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

import Foundation

/**
 API Error
 
 Represents errors that can be returned from the API
 */
public class APIError: FrolloSDKError, ResponseError {
    
    /**
     API Error Type
     
     Type of error that has occurred on the API
     */
    public enum APIErrorType: String {
        
        /// Deprecated API
        case deprecated
        
        /// Server is under maintenance
        case maintenance
        
        /// API is not implemented
        case notImplemented
        
        /// Rate limit for the API has been exceeded. Back off and try again
        case rateLimit
        
        /// Server has encountered a critical error
        case serverError
        
        /// Bad request
        case badRequest
        
        /// Unauthorised
        case unauthorised
        
        /// Object not found
        case notFound
        
        /// Object already exists
        case alreadyExists
        
        /// New password must be different from old password
        case passwordMustBeDifferent
        
        /// Invalid access token
        case invalidAccessToken
        
        /// Invalid refresh token
        case invalidRefreshToken
        
        /// Username and/or password is wrong
        case invalidUsernamePassword
        
        /// Device has been suspended
        case suspendedDevice
        
        /// User has been suspended
        case suspendedUser
        
        /// User account locked
        case accountLocked
        
        /// An unknown issue with authorisation has occurred
        case otherAuthorisation
        
        /// Unknown error
        case unknown
        
    }
    
    /// Debug description
    public var debugDescription: String {
        return localizedAPIErrorDebugDescription()
    }
    
    /// Localized description
    public var errorDescription: String? {
        return localizedAPIErrorDescription()
    }
    
    /// Type of API Error
    public var type: APIErrorType
    
    /// Error code returned by the API if available and recognised
    public var errorCode: APIErrorCode?
    
    /// Error message returned by the API if available
    public var message: String?
    
    /// Status code received from the API
    public var statusCode: Int
    
    internal required init(statusCode: Int, response: Data?) {
        self.statusCode = statusCode
        
        var errorResponse: APIErrorResponse?
        
        if let json = response {
            let decoder = JSONDecoder()
            do {
                errorResponse = try decoder.decode(APIErrorResponse.self, from: json)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        self.message = errorResponse?.error.errorMessage
        self.errorCode = errorResponse?.error.errorCode
        
        switch statusCode {
            case 400:
                if let errorCode = errorResponse?.error.errorCode {
                    switch errorCode {
                        case .invalidMustBeDifferent:
                            self.type = .passwordMustBeDifferent
                        default:
                            self.type = .badRequest
                    }
                } else {
                    self.type = .badRequest
                }
                
            case 401:
                if let errorCode = errorResponse?.error.errorCode {
                    switch errorCode {
                        case .invalidAccessToken:
                            self.type = .invalidAccessToken
                        case .invalidRefreshToken:
                            self.type = .invalidRefreshToken
                        case .invalidUsernamePassword:
                            self.type = .invalidUsernamePassword
                        case .suspendedDevice:
                            self.type = .suspendedDevice
                        case .suspendedUser:
                            self.type = .suspendedUser
                        case .accountLocked:
                            self.type = .accountLocked
                        default:
                            self.type = .otherAuthorisation
                    }
                } else {
                    self.type = .otherAuthorisation
                }
                
            case 403:
                self.type = .unauthorised
                
            case 404:
                self.type = .notFound
                
            case 409:
                self.type = .alreadyExists
                
            case 410:
                self.type = .deprecated
                
            case 429:
                self.type = .rateLimit
                
            case 500, 503, 504:
                self.type = .serverError
                
            case 501:
                self.type = .notImplemented
                
            case 502:
                self.type = .maintenance
                
            default:
                self.type = .unknown
        }
    }
    
    // MARK: - Descriptions
    
    private func localizedAPIErrorDescription() -> String {
        switch type {
            case .accountLocked:
                return Localization.string("Error.API.AccountLocked")
            case .alreadyExists:
                return Localization.string("Error.API.UserAlreadyExists")
            case .badRequest:
                return Localization.string("Error.API.BadRequest")
            case .deprecated:
                return Localization.string("Error.API.DeprecatedError")
            case .invalidAccessToken:
                return Localization.string("Error.API.InvalidAccessToken")
            case .invalidRefreshToken:
                return Localization.string("Error.API.InvalidRefreshToken")
            case .invalidUsernamePassword:
                return Localization.string("Error.API.InvalidUsernamePassword")
            case .maintenance:
                return Localization.string("Error.API.Maintenance")
            case .notFound:
                return Localization.string("Error.API.NotFound")
            case .notImplemented:
                return Localization.string("Error.API.NotImplemented")
            case .otherAuthorisation:
                return Localization.string("Error.API.UnknownAuthorisation")
            case .passwordMustBeDifferent:
                return Localization.string("Error.API.PasswordMustBeDifferent")
            case .rateLimit:
                return Localization.string("Error.API.RateLimit")
            case .serverError:
                return Localization.string("Error.API.ServerError")
            case .suspendedDevice:
                return Localization.string("Error.API.SuspendedDevice")
            case .suspendedUser:
                return Localization.string("Error.API.SuspendedUser")
            case .unauthorised:
                return Localization.string("Error.API.Unauthorised")
            case .unknown:
                return Localization.string("Error.API.UnknownError")
        }
    }
    
    private func localizedAPIErrorDebugDescription() -> String {
        var debug = "APIError: Type [\(type.rawValue)] HTTP Status Code: \(statusCode) "
        
        if let code = errorCode {
            debug.append(code.rawValue + ": ")
        }
        if let msg = message {
            debug.append(msg + " | ")
        }
        
        debug.append(localizedAPIErrorDescription())
        
        return debug
    }
    
}
