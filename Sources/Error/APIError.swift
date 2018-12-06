//
//  APIError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class APIError: FrolloSDKError {
    
    enum APIErrorType: String {
        case deprecated
        
        case maintenance
        case notImplemented
        case rateLimit
        case serverError
        
        case badRequest
        case unauthorised
        case notFound
        case alreadyExists
        case passwordMustBeDifferent
        
        case invalidAccessToken
        case invalidRefreshToken
        case invalidUsernamePassword
        case suspendedDevice
        case suspendedUser
        case otherAuthorisation
        
        case unknown
    }
    
    public var debugDescription: String {
        get {
            return localizedAPIErrorDebugDescription()
        }
    }
    public var localizedDescription: String {
        get {
            return localizedAPIErrorDescription()
        }
    }
    
    /// Type of API Error
    public var type: APIErrorType
    /// Error code returned by the API if available and recognised
    public var errorCode: APIErrorResponse.APIErrorCode?
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
