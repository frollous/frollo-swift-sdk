//
//  OAuthTokenResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct OAuthTokenResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case createdAt = "created_at"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
    
    let accessToken: String
    let createdAt: Date?
    let expiresIn: Double
    let refreshToken: String
    let tokenType: String
    
}
