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
@testable import FrolloSDK

extension OAuth2TokenRequest {
    
    static func testLoginValidData() -> OAuth2TokenRequest {
        return OAuth2TokenRequest(audience: "https://api.example.com/api/v2",
                                 clientID: String.randomString(length: 32),
                                 code: nil,
                                 codeVerifier: nil,
                                 domain: "api.example.com",
                                 grantType: .password,
                                 legacyToken: nil,
                                 password: String.randomString(range: 8...32),
                                 redirectURI: nil,
                                 refreshToken: nil,
                                 scope: OAuth2TokenRequest.Scope.offlineAccess.rawValue,
                                 username: "user@example.com",
                                 realm: nil)
    }
    
    static func testLoginInvalidData() -> OAuth2TokenRequest {
        return OAuth2TokenRequest(audience: "https://api.example.com/api/v2",
                                 clientID: String.randomString(length: 32),
                                 code: nil,
                                 codeVerifier: nil,
                                 domain: "api.example.com",
                                 grantType: .password,
                                 legacyToken: nil,
                                 password: nil,
                                 redirectURI: nil,
                                 refreshToken: nil,
                                 scope: nil,
                                 username: "user@example.com",
                                 realm: nil)
    }
    
//    static func testTokenRefreshData() -> OAuthTokenRequest {
//
//    }
    
}
