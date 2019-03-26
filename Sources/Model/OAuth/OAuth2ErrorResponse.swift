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

import Foundation

public struct OAuth2ErrorResponse: Codable {
    
    /// Type of Error
    public enum ErrorType: String, Codable, CaseIterable {
        
        /// The request is missing a parameter so the server can’t proceed with the request.
        case invalidRequest = "invalid_request"
        
        /// Client authentication failed, such as if the request contains an invalid client ID or secret.
        case invalidClient = "invalid_client"
        
        /// The authorization code (or user’s password for the password grant type) is invalid or expired.
        case invalidGrant = "invalid_grant"
        
        /// For access token requests that include a scope (password or client_credentials grants), this error indicates an invalid scope value in the request.
        case invalidScope = "invalid_scope"
        
        /// This client is not authorized to use the requested grant type.
        case unauthorizedClient = "unauthorized_client"
        
        /// If a grant type is requested that the authorization server doesn’t recognize, use this code.
        case unsupportedGrantType = "unsupported_grant_type"
        
        /// Server error
        case serverError = "server_error"
        
        /// Any other errors, default value
        case oAuth2Error = "oauth2_error"
    }
    
    /// Coding keys
    public enum CodingKeys: String, CodingKey {
        case errorDescription = "error_description"
        case errorUri = "error_uri"
        case errorType = "error"
    }
    
    /// Type of error
    public let errorType: ErrorType
    
    /// Description or error
    public let errorDescription: String?
    
    /// Optional Uri from Authentication Server
    public let errorUri: String?
    
}
