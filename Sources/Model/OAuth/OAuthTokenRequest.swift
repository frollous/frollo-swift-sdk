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
        case username
    }
    
    let audience: String
    let clientID: String
    let code: String?
    let codeVerifier: String?
    let domain: String
    let grantType: GrantType
    let legacyToken: String?
    let password: String?
    let redirectURI: String?
    let refreshToken: String?
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
