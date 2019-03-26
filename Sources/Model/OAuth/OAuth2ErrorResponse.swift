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

internal struct OAuth2ErrorResponse: Codable {
    
    /// Coding keys
    internal enum CodingKeys: String, CodingKey {
        case errorDescription = "error_description"
        case errorUri = "error_uri"
        case errorType = "error"
    }
    
    /// Type of error
    internal let errorType: OAuth2Error.OAuth2ErrorType
    
    /// Description or error
    internal let errorDescription: String?
    
    /// Optional URI from Authentication Server
    internal let errorUri: String?
    
}
