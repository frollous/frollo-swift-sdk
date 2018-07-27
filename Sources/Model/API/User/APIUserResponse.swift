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
        case dateOfBirth = "date_of_birth"
        case email
        case emailVerified = "email_verified"
        case facebookID = "facebook_id"
        case firstName = "first_name"
        case gender
        case householdSize = "household_size"
        case householdType = "marital_status"
        case industry
        case lastName = "last_name"
        case occupation
        case primaryCurrency = "primary_currency"
        case status
        case userID = "id"
        case validPassword = "valid_password"
    }
    
    struct Address: Codable {
        var postcode: String
    }
    
    let email: String
    let emailVerified: Bool
    let firstName: String
    let primaryCurrency: String
    let status: User.Status
    let userID: Int64
    let validPassword: Bool
    
    var address: Address?
    var dateOfBirth: Date?
    var facebookID: String?
    var gender: User.Gender?
    var householdSize: Int64?
    var householdType: User.HouseholdType?
    var industry: User.Industry?
    var lastName: String?
    var occupation: User.Occupation?
    
}
