//
//  APIProviderAccountCreateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIProviderAccountCreateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case loginForm = "login_form"
        case providerID = "provider_id"
    }
    
    let loginForm: ProviderLoginForm
    let providerID: Int64
    
}
