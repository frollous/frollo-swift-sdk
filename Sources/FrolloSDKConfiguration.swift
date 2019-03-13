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

/// Configuration of the SDK and additional optional preferences
public struct FrolloSDKConfiguration {
    
    /// Level of logging for debug and error messages. Default is `error`
    public var logLevel: LogLevel = .error
    
    /// Enable or disable public key pinning for *.frollo.us domains- useful for disabling in debug mode
    public var publicKeyPinningEnabled: Bool = true
    
    /**
     Generate Manual OAuth2 SDK configuration
     
     Generates a valid SDK configuration for setting up the SDK. This configuration uses manually specified URLs the authorization and token endpoints the SDK should use.
     Optional preferences can be set before running `FrolloSDK.setup()`
     
     - parameters:
         - clientID: OAuth2 Client identifier. The unique identifier of the application implementing the SDK
         - redirectURL: OAuth2 Redirection URL. URL to redirect to after the authorization flow is complete. This should be a deep or universal link to the host app
         - authorizationEndpoint: URL of the OAuth2 authorization endpoint for web based login
         - tokenEndpoint: URL of the OAuth2 token endpoint for getting tokens and native login
         - serverEndpoint: Base URL of the Frollo API this SDK should point to
     
     - returns: Valid configuration
     */
    public init(clientID: String, redirectURL: URL, authorizationEndpoint: URL, tokenEndpoint: URL, serverEndpoint: URL) {
        self.authorizationEndpoint = authorizationEndpoint
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.serverEndpoint = serverEndpoint
        self.tokenEndpoint = tokenEndpoint
    }
    
    internal let authorizationEndpoint: URL
    internal let clientID: String
    internal let redirectURL: URL
    internal let serverEndpoint: URL
    internal let tokenEndpoint: URL
    
}
