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
        case dateOfBirth = "date_of_birth"
        case email
        case firstName = "first_name"
        case gender
        case householdSize = "household_size"
        case householdType = "marital_status"
        case industry
        case lastName = "last_name"
        case occupation
        case primaryCurrency = "primary_currency"
    }
    
    struct Address: Codable {
        var postcode: String
    }
    
    let email: String
    let firstName: String
    let primaryCurrency: String
    
    var address: Address?
    var dateOfBirth: Date?
    var gender: User.Gender?
    var householdSize: Int64?
    var householdType: User.HouseholdType?
    var industry: User.Industry?
    var lastName: String?
    var occupation: User.Occupation?
    
}
