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

extension FrolloSDKConfiguration {
    
    static let authorizationEndpoint = URL(string: "https://id.example.com/oauth/authorize")!
    static let redirectURL = URL(string: "app://redirect")!
    static let revokeTokenEndpoint = URL(string: "https://id.example.com/oauth/revoke")
    static let tokenEndpoint = URL(string: "https://id.example.com/oauth/token")!
    
    static func testConfig() -> FrolloSDKConfiguration {
        return FrolloSDKConfiguration(authenticationType: .oAuth2(redirectURL: redirectURL,
                                                                  authorizationEndpoint: authorizationEndpoint,
                                                                  tokenEndpoint: tokenEndpoint,
                                                                  revokeTokenEndpoint: revokeTokenEndpoint,
                                                                  audience: nil,
                                                                  supportsRealm: false),
                                      clientID: "abc123",
                                      serverEndpoint: URL(string: "https://api.example.com")!)
    }
    
}
