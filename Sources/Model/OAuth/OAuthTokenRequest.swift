//
//  OAuthTokenRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct OAuthTokenRequest: Codable {
    
    enum GrantType: String, Codable, CaseIterable {
        case authorizationCode = "authorization_code"
        case password
        case refreshToken = "refresh_token"
    }
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case code
        case domain
        case grantType = "grant_type"
        case legacyToken = "frollo_legacy_token"
        case password
        case refreshToken = "refresh_token"
        case username
    }
    
    let clientID: String
    let clientSecret: String
    let code: String?
    let domain: String
    let grantType: GrantType
    let legacyToken: String?
    let password: String?
    let refreshToken: String?
    let username: String?
    
    var valid: Bool {
        get {
            switch grantType {
                case .authorizationCode:
                    return code != nil
                case .password:
                    return (password != nil && username != nil) || legacyToken != nil
                case .refreshToken:
                    return refreshToken != nil
            }
        }
    }
    
}
