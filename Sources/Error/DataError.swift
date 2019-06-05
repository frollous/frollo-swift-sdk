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
 Data Error
 
 Error caused by an issue with data or data storage
 */
public class DataError: FrolloSDKError {
    
    /**
     Data Error Type
     
     High level type of the error
     */
    public enum DataErrorType: String {
        
        /// API data error - intercepts potential issues before being sent to API
        case api
        
        /// Authentication error
        case authentication
        
        /// Database error - issues with the Core Data
        case database
        
        /// Unknown
        case unknown
        
    }
    
    /**
     Data Error Sub Type
     
     Detailed type of the error
     */
    public enum DataErrorSubType: String {
        
        /// API - Invalid Data
        case invalidData
        
        /// API - Password too short
        case passwordTooShort
        
        /// API - Revoke token URL not provided
        case revokeTokenURLMissing
        
        /// Authentication - Already logged in
        case alreadyLoggedIn
        
        /// Authentication - User not logged in
        case loggedOut
        
        /// Authentication - Missing access token from keychain
        case missingAccessToken
        
        /// Authentication - Missing refresh token from keychain
        case missingRefreshToken
        
        /// Database - Corrupted
        case corrupt
        
        /// Database - Disk full, no free space to continue operating
        case diskFull
        
        /// Database - Migration upgrade failed
        case migrationFailed
        
        /// Database - Store not found
        case notFound
        
        /// Unknown
        case unknown
    }
    
    /// Data error type
    public var type: DataErrorType
    
    /// More detailed sub type of the error
    public var subType: DataErrorSubType
    
    /// System error if available
    public var systemError: Error?
    
    /// Debug description
    public var debugDescription: String {
        return debugDataErrorDescription()
    }
    
    /// Error description
    public var errorDescription: String? {
        return localizedDataErrorDescription()
    }
    
    internal init(type: DataErrorType, subType: DataErrorSubType) {
        self.type = type
        self.subType = subType
    }
    
    // MARK: - Error Descriptions
    
    private func localizedDataErrorDescription() -> String {
        switch type {
            case .api:
                switch subType {
                    case .invalidData:
                        return Localization.string("Error.Data.API.InvalidData")
                    case .passwordTooShort:
                        return Localization.string("Error.Data.API.PasswordTooShort")
                    case .revokeTokenURLMissing:
                        return Localization.string("Error.Data.API.RevokeTokenURLMissing")
                    default:
                        return Localization.string("Error.Data.API.Unknown")
                }
            case .authentication:
                switch subType {
                    case .alreadyLoggedIn:
                        return Localization.string("Error.Data.Authentication.AlreadyLoggedIn")
                    case .loggedOut:
                        return Localization.string("Error.Data.Authentication.LoggedOut")
                    case .missingAccessToken:
                        return Localization.string("Error.Data.Authentication.MissingAccessToken")
                    case .missingRefreshToken:
                        return Localization.string("Error.Data.Authentication.MissingRefreshToken")
                    default:
                        return Localization.string("Error.Data.Authentication.Unknown")
                        
                }
                
            case .database:
                switch subType {
                    case .corrupt:
                        return Localization.string("Error.Data.Database.Corrupted")
                    case .diskFull:
                        return Localization.string("Error.Data.Database.DiskFullError")
                    case .migrationFailed:
                        return Localization.string("Error.Data.Database.MigrationFailed")
                    case .notFound:
                        return Localization.string("Error.Data.Database.NotFound")
                    default:
                        return Localization.string("Error.Data.Database.UnknownError")
                }
                
            case .unknown:
                switch subType {
                    case .unknown:
                        return Localization.string("Error.Generic.UnknownError")
                    default:
                        return Localization.string("Error.Generic.UnknownError")
                }
        }
    }
    
    private func debugDataErrorDescription() -> String {
        return "DataError: " + type.rawValue + "." + subType.rawValue + ": " + localizedDescription
    }
    
}
