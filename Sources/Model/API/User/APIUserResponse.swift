//
//  APIUserResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIUserResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case address
        case attribution
        case dateOfBirth = "date_of_birth"
        case email
        case emailVerified = "email_verified"
        case facebookID = "facebook_id"
        case features
        case firstName = "first_name"
        case gender
        case householdSize = "household_size"
        case householdType = "marital_status"
        case industry
        case lastName = "last_name"
        case mobileNumber = "mobile_number"
        case occupation
        case primaryCurrency = "primary_currency"
        case previousAddress = "previous_address"
        case status
        case userID = "id"
        case validPassword = "valid_password"
        
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
    let emailVerified: Bool
    let firstName: String
    let primaryCurrency: String
    let status: User.Status
    let userID: Int64
    let validPassword: Bool
    
    let address: Address?
    let attribution: Attribution?
    let dateOfBirth: Date?
    let facebookID: String?
    let features: [User.FeatureFlag]?
    let gender: User.Gender?
    let householdSize: Int64?
    let householdType: User.HouseholdType?
    let industry: User.Industry?
    let lastName: String?
    let mobileNumber: String?
    let occupation: User.Occupation?
    let previousAddress: Address?

}
