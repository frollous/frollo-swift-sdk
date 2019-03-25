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

public class OAuth2Error: FrolloSDKError {
    
    public var debugDescription: String
    public var error: String
    
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
        self.error = errorResponse?.error.rawValue ?? ""
    }
}

internal enum ErrorType: String {
    case OAuth2
    case Normal
}
