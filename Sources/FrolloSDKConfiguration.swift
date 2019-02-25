//
//  FrolloSDKConfiguration.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
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
         - clientSecret: OAuth2 Client secret. The client secret of the application implementing the SDK. Required due to legacy reasons and should not be considered secure
         - redirectURI: OAuth2 Redirection URI. URI to redirect to after the authorization flow is complete. This should be a deep or universal link to the host app
         - authorizationEndpoint: URL of the OAuth2 authorization endpoint for web based login
         - tokenEndpoint: URL of the OAuth2 token endpoint for getting tokens and native login
         - serverEndpoint: Base URL of the Frollo API this SDK should point to
     
     - returns: Valid configuration
     */
    public init(clientID: String, clientSecret: String, redirectURI: String, authorizationEndpoint: URL, tokenEndpoint: URL, serverEndpoint: URL) {
        self.authorizationEndpoint = authorizationEndpoint
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.serverEndpoint = serverEndpoint
        self.tokenEndpoint = tokenEndpoint
    }
    
    internal let authorizationEndpoint: URL
    internal let clientID: String
    internal let clientSecret: String
    internal let redirectURI: String
    internal let serverEndpoint: URL
    internal let tokenEndpoint: URL
    
}
