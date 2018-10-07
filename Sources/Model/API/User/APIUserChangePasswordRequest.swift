//
//  APIUserChangePasswordRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIUserChangePasswordRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }
    
    let currentPassword: String?
    let newPassword: String
    
}
