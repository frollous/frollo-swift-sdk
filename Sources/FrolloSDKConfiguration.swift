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
    
    /// Authentication method to be used by the SDK. Includes authentication specific parameters
    public enum AuthenticationType {
        
        /// Custom - provide a custom authentication class managed externally from the SDK
        ///
        /// - authentication: Custom authentication method. See `OAuth2Authentication` for a default implementation.
        case custom(authentication: Authentication)
        
        /// OAuth2 - generic OAuth2 based authentication
        ///
        /// - clientID: OAuth2 Client identifier. The unique identifier of the application implementing the SDK
        /// - redirectURL: OAuth2 Redirection URL. URL to redirect to after the authorization flow is complete. This should be a deep or universal link to the host app
        /// - authorizationEndpoint: URL of the OAuth2 authorization endpoint for web based login
        /// - tokenEndpoint: URL of the OAuth2 token endpoint for getting tokens and native login
        /// - revokeTokenEndpoint: URL of the OAuth2 revoke endpoint if supported
        case oAuth2(clientID: String, redirectURL: URL, authorizationEndpoint: URL, tokenEndpoint: URL, revokeTokenEndpoint: URL?)
        
    }
    
    /// Level of logging for debug and error messages. Default is `error`
    public var logLevel: LogLevel = .error
    
    /// Enable or disable public key pinning for *.frollo.us domains- useful for disabling in debug mode
    public var publicKeyPinningEnabled: Bool = true
    
    /// (Optional) Set the name of the target using the SDK to enable Core Data persistent history tracking across multiple targets using the same database. For example if you have a watch app and iOS app using the same shared FrolloSDK database and login you can setup targetNames of "app" and "watch" respectively to trigger Core Data updates in contexts across targets. Default is nil and the feature will be disabled. See https://developer.apple.com/documentation/coredata/nspersistenthistorychangerequest
    public var targetName: String?
    
    /**
     Generate SDK configuration
     
     Generates a valid SDK configuration for setting up the SDK. This configuration specifies the authentication method and required parameters to be used.
     Optional preferences can be set before running `FrolloSDK.setup()`
     
     - parameters:
         - authenticationType: Type of authentication to be used. Valid options are `custom` and `oAuth2`
         - dataDirectory: Data directory to store data. Default is Application Support but can be overriden to support application groups
         - serverEndpoint: Base URL of the Frollo API this SDK should point to
     
     - returns: Valid configuration
     */
    public init(authenticationType: AuthenticationType, dataDirectory: URL = FrolloSDK.defaultDataFolderURL, serverEndpoint: URL) {
        self.authenticationType = authenticationType
        self.dataDirectory = dataDirectory
        self.serverEndpoint = serverEndpoint
    }
    
    internal let authenticationType: AuthenticationType
    internal let dataDirectory: URL
    internal let serverEndpoint: URL
    
}
