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
        
        case address
        case dateOfBirth = "date_of_birth"
        case deviceID = "device_id"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case mobileNumber = "mobile_number"
        case password
        
    }
    
    struct Address: Codable {
        
        let postcode: String
        
    }
    
    let deviceID: String
    let deviceName: String
    let deviceType: String
    let email: String
    let firstName: String
    let password: String
    
    let address: Address?
    let dateOfBirth: Date?
    let lastName: String?
    let mobileNumber: String?
    
}
