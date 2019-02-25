//
//  OAuthTokenRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 22/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension OAuthTokenRequest {
    
    static func testLoginValidData() -> OAuthTokenRequest {
        return OAuthTokenRequest(clientID: String.randomString(length: 32),
                                 clientSecret: String.randomString(length: 32),
                                 code: nil,
                                 domain: "api.example.com",
                                 grantType: .password,
                                 legacyToken: nil,
                                 password: String.randomString(range: 8...32),
                                 refreshToken: nil,
                                 username: "user@example.com")
    }
    
    static func testLoginInvalidData() -> OAuthTokenRequest {
        return OAuthTokenRequest(clientID: String.randomString(length: 32),
                                 clientSecret: String.randomString(length: 32),
                                 code: nil,
                                 domain: "api.example.com",
                                 grantType: .password,
                                 legacyToken: nil,
                                 password: nil,
                                 refreshToken: nil,
                                 username: "user@example.com")
    }
    
//    static func testTokenRefreshData() -> OAuthTokenRequest {
//
//    }
    
}
