//
//  APIProviderAccountUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 17/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIProviderAccountUpdateRequest: Codable {

    enum CodingKeys: String, CodingKey {
        case loginForm = "login_form"
    }
    
    let loginForm: ProviderLoginForm
    
}
