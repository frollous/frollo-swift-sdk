//
//  APIError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 API Error
 
 Represents errors that can be returned from the API
 */
public class APIError: FrolloSDKError {
    
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
        get {
            return localizedAPIErrorDebugDescription()
        }
    }
    /// Localized description
    public var errorDescription: String? {
        get {
            return localizedAPIErrorDescription()
        }
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
        
        message = errorResponse?.error.errorMessage
        errorCode = errorResponse?.error.errorCode
        
        switch statusCode {
            case 400:
                if let errorCode = errorResponse?.error.errorCode {
                    switch errorCode {
                        case .invalidMustBeDifferent:
                            type = .passwordMustBeDifferent
                        default:
                            type = .badRequest
                    }
                } else {
                    type = .badRequest
                }
            
            case 401:
                if let errorCode = errorResponse?.error.errorCode {
                    switch errorCode {
                        case .invalidAccessToken:
                            type = .invalidAccessToken
                        case .invalidRefreshToken:
                            type = .invalidRefreshToken
                        case .invalidUsernamePassword:
                            type = .invalidUsernamePassword
                        case .suspendedDevice:
                            type = .suspendedDevice
                        case .suspendedUser:
                            type = .suspendedUser
                        case .accountLocked:
                            type = .accountLocked
                        default:
                            type = .otherAuthorisation
                    }
                } else {
                    type = .otherAuthorisation
                }
            
            case 403:
                type = .unauthorised
            
            case 404:
                type = .notFound
            
            case 409:
                type = .alreadyExists
            
            case 410:
                type = .deprecated
            
            case 429:
                type = .rateLimit
            
            case 500, 503, 504:
                type = .serverError
            
            case 501:
                type = .notImplemented
            
            case 502:
                type = .maintenance
            
            default:
                type = .unknown
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
