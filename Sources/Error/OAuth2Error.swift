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

/**
 OAuth2 Error
 
 Represents errors that can be returned from OAuth2 authorization flow
 */
public class OAuth2Error: FrolloSDKError {
    
    /// Debug description
    public let debugDescription: String
    
    /// Type of OAuth2 Error
    public let type: String
    
    /// Optional error uri returned from authentication server
    public let errorUri: String?
    
    internal required init(response: Data?) {
        
        var errorResponse: OAuth2ErrorResponse?
        
        if let json = response {
            let decoder = JSONDecoder()
            do {
                errorResponse = try decoder.decode(OAuth2ErrorResponse.self, from: json)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        self.debugDescription = errorResponse?.errorDescription ?? ""
        self.type = errorResponse?.errorType.rawValue ?? OAuth2ErrorResponse.ErrorType.oAuth2Error.rawValue
        self.errorUri = errorResponse?.errorUri
    }
}

/// Type of error to expect. OAuth2 if error form authentication server otherwise normal
internal enum ErrorType: String {
    case OAuth2
    case Normal
}
