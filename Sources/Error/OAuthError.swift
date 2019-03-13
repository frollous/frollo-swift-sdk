//
// Copyright © 2019 Frollo. All rights reserved.
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

#if CORE && os(iOS)
import AppAuthCore
#elseif os(tvOS)
import AppAUth
#else
import AppAuth
#endif

/**
 OAuth Error
 
 Represents errors that can be returned from the authorization flow
 */
public class OAuthError: FrolloSDKError {
    
    /**
     OAuth Error Type
     
     Type of error that has occurred during authorization
     */
    public enum OAuthErrorType: String {
        
        /// Access denied
        case accessDenied
        
        /// Client error
        case clientError
        
        /// Invalid client
        case invalidClient
        
        /// Invalid client metadata
        case invalidClientMetadata
        
        /// Invalid grant
        case invalidGrant
        
        /// Invalid redirect URL
        case invalidRedirectURI
        
        /// Invalid request
        case invalidRequest
        
        /// Invalid scope
        case invalidScope
        
        /// Unauthorized client
        case unauthorizedClient
        
        /// Unsupported grant type
        case unsupportedGrantType
        
        /// Unsupported response type
        case unsupportedResponseType
        
        /// The browser could not be opened
        case browserError
        
        /// A network error occurred during authentication
        case networkError
        
        /// A server error occurred during authentication
        case serverError
        
        /// User cancelled the authentication request
        case userCancelled
        
        /// An unknown issue with authorisation has occurred
        case otherAuthorisation
        
        /// Unknown error
        case unknown
        
    }
    
    /// Debug description
    public var debugDescription: String {
        return localizedOAuthErrorDebugDescription()
    }
    
    /// Localized description
    public var errorDescription: String? {
        return localizedOAuthErrorDescription()
    }
    
    /// Type of OAuth Error
    public var type: OAuthErrorType
    
    /// System error if available
    public var systemError: Error?
    
    internal required init(error: NSError) {
        self.systemError = error
        
        if error.domain == OIDGeneralErrorDomain {
            if let errorCode = OIDErrorCode(rawValue: error.code) {
                switch errorCode {
                    case .networkError:
                        self.type = .networkError
                        
                    case .safariOpenError:
                        self.type = .browserError
                        
                    case .userCanceledAuthorizationFlow:
                        self.type = .userCancelled
                        
                    default:
                        self.type = .otherAuthorisation
                }
            } else {
                self.type = .unknown
            }
        } else if error.domain == OIDOAuthAuthorizationErrorDomain {
            if let authErrorCode = OIDErrorCodeOAuth(rawValue: error.code) {
                switch authErrorCode {
                    case .accessDenied:
                        self.type = .accessDenied
                    case .clientError:
                        self.type = .clientError
                    case .invalidClient:
                        self.type = .invalidClient
                    case .invalidClientMetadata:
                        self.type = .invalidClientMetadata
                    case .invalidGrant:
                        self.type = .invalidGrant
                    case .invalidRedirectURI:
                        self.type = .invalidRedirectURI
                    case .invalidRequest:
                        self.type = .invalidRequest
                    case .invalidScope:
                        self.type = .invalidScope
                    case .other:
                        self.type = .otherAuthorisation
                    case .serverError, .temporarilyUnavailable:
                        self.type = .serverError
                    case .unauthorizedClient:
                        self.type = .unauthorizedClient
                    case .unsupportedGrantType:
                        self.type = .unsupportedGrantType
                    case .unsupportedResponseType:
                        self.type = .unsupportedResponseType
                }
            } else {
                self.type = .otherAuthorisation
            }
        } else {
            self.type = .unknown
        }
    }
    
    // MARK: - Descriptions
    
    private func localizedOAuthErrorDescription() -> String {
        switch type {
            case .accessDenied:
                return Localization.string("Error.OAuth.AccessDenied")
            case .browserError:
                return Localization.string("Error.OAuth.BrowserError")
            case .clientError:
                return Localization.string("Error.OAuth.ClientError")
            case .invalidClient:
                return Localization.string("Error.OAuth.InvalidClient")
            case .invalidClientMetadata:
                return Localization.string("Error.OAuth.InvalidClientMetadata")
            case .invalidGrant:
                return Localization.string("Error.OAuth.InvalidGrant")
            case .invalidRedirectURI:
                return Localization.string("Error.OAuth.InvalidRedirectURI")
            case .invalidRequest:
                return Localization.string("Error.OAuth.InvalidRequest")
            case .invalidScope:
                return Localization.string("Error.OAuth.InvalidScope")
            case .networkError:
                return Localization.string("Error.OAuth.NetworkError")
            case .otherAuthorisation:
                return Localization.string("Error.OAuth.OtherAuthorisation")
            case .serverError:
                return Localization.string("Error.OAuth.ServerError")
            case .unauthorizedClient:
                return Localization.string("Error.OAuth.UnauthorizedClient")
            case .unsupportedGrantType:
                return Localization.string("Error.OAuth.UnsupportedGrantType")
            case .unsupportedResponseType:
                return Localization.string("Error.OAuth.UnsupportedResponseType")
            case .unknown:
                return Localization.string("Error.OAuth.Unknown")
            case .userCancelled:
                return Localization.string("Error.OAuth.UserCancelled")
        }
    }
    
    private func localizedOAuthErrorDebugDescription() -> String {
        var debug = "OAuthError: Type [\(type.rawValue)] "
        
        debug.append(localizedOAuthErrorDescription())
        
        return debug
    }
    
}
