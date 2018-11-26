//
//  APIUserUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIUserUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case address
        case attribution
        case dateOfBirth = "date_of_birth"
        case email
        case firstName = "first_name"
        case gender
        case householdSize = "household_size"
        case householdType = "marital_status"
        case industry
        case lastName = "last_name"
        case mobileNumber = "mobile_number"
        case occupation
        case primaryCurrency = "primary_currency"
    }
    
    struct Address: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case line1 = "line_1"
            case line2 = "line_2"
            case postcode
            case suburb
            
        }
        
        let line1: String?
        let line2: String?
        let postcode: String?
        let suburb: String?
        
    }
    
    struct Attribution: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case adGroup = "ad_group"
            case campaign
            case creative
            case network
            
        }
        
        let adGroup: String?
        let campaign: String?
        let creative: String?
        let network: String?
        
    }
    
    let email: String
    let firstName: String
    let primaryCurrency: String
    
    var address: Address?
    var attribution: Attribution?
    var dateOfBirth: Date?
    var gender: User.Gender?
    var householdSize: Int64?
    var householdType: User.HouseholdType?
    var industry: User.Industry?
    var lastName: String?
    var mobileNumber: String?
    var occupation: User.Occupation?
    
}
