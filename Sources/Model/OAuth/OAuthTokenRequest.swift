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

struct OAuthTokenRequest: Codable {
    
    enum GrantType: String, Codable, CaseIterable {
        case authorizationCode = "authorization_code"
        case password
        case refreshToken = "refresh_token"
    }
    
    enum Scope: String, Codable, CaseIterable {
        case offlineAccess = "offline_access"
    }
    
    enum CodingKeys: String, CodingKey {
        case audience
        case clientID = "client_id"
        case code
        case codeVerifier = "code_verifier"
        case domain
        case grantType = "grant_type"
        case legacyToken = "frollo_legacy_token"
        case password
        case redirectURI = "redirect_uri"
        case refreshToken = "refresh_token"
        case scope
        case username
    }
    
    let audience: String?
    let clientID: String
    let code: String?
    let codeVerifier: String?
    let domain: String
    let grantType: GrantType
    let legacyToken: String?
    let password: String?
    let redirectURI: String?
    let refreshToken: String?
    let scope: String?
    let username: String?
    
    var valid: Bool {
        switch grantType {
            case .authorizationCode:
                return code != nil && redirectURI != nil
            case .password:
                return (password != nil && username != nil) || legacyToken != nil
            case .refreshToken:
                return refreshToken != nil
        }
    }
    
}
