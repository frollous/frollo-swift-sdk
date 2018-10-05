//
//  APIUserRegisterRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIUserRegisterRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case password
    }
    
    let deviceID: String
    let deviceName: String
    let deviceType: String
    let email: String
    let firstName: String
    let password: String
    
    var lastName: String?
    
}
