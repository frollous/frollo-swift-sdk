//
//  APITokenResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APITokenResponse: Codable {
    
    enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
        case accessTokenExpiry = "access_token_exp"
        case refreshToken = "refresh_token"
    }
    
    let accessToken: String
    let accessTokenExpiry: Date
    let refreshToken: String
    
}
