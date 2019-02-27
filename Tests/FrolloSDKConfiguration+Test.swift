//
//  FrolloSDKConfiguration+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension FrolloSDKConfiguration {
    
    static func testConfig() -> FrolloSDKConfiguration {
        return FrolloSDKConfiguration(clientID: "abc123",
                                      redirectURL: URL(string: "app://redirect")!,
                                      authorizationEndpoint: URL(string: "https://id.example.com/oauth/authorize")!,
                                      tokenEndpoint: URL(string: "https://id.example.com/oauth/token")!,
                                      serverEndpoint: URL(string: "https://api.example.com")!)
    }
    
}
