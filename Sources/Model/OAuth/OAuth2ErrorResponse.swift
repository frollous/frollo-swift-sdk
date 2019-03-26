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
    
    public enum ErrorType: String, Codable, CaseIterable {
        case invalidRequest = "invalid_request"
        case invalidClient = "invalid_client"
        case invalidGrant = "invalid_grant"
        case invalidScope = "invalid_scope"
        case unauthorizedClient = "unauthorized_client"
        case unsupportedGrantType = "unsupported_grant_type"
        case serverError = "server_error"
        case oAuth2Error = "oauth2_error"
    }
    
    public enum CodingKeys: String, CodingKey {
        case errorDescription = "error_description"
        case errorUri = "error_uri"
        case errorType = "error"
    }
    
    public let errorType: ErrorType
    public let errorDescription: String?
    public let errorUri: String?
    
}
