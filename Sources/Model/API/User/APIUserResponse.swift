//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

struct APIUserResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case attribution
        case currentAddress = "current_address"
        case dateOfBirth = "date_of_birth"
        case email
        case emailVerified = "email_verified"
        case facebookID = "facebook_id"
        case features
        case firstName = "first_name"
        case foreignTax = "foreign_tax"
        case gender
        case householdSize = "household_size"
        case householdType = "marital_status"
        case industry
        case lastName = "last_name"
        case mailingAddress = "mailing_address"
        case mobileNumber = "mobile_number"
        case occupation
        case primaryCurrency = "primary_currency"
        case registerSteps = "register_steps"
        case status
        case taxResidency = "tax_residency"
        case tfn
        case tin
        case userID = "id"
        case validPassword = "valid_password"
        
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
    let primaryCurrency: String
    let status: User.Status
    let userID: Int64
    let validPassword: Bool
    let currentAddress: User.Address?
    let mailingAddress: User.Address?
    let attribution: Attribution?
    let dateOfBirth: Date?
    let facebookID: String?
    let features: [User.FeatureFlag]?
    let firstName: String?
    let gender: User.Gender?
    let householdSize: Int64?
    let householdType: User.HouseholdType?
    let industry: User.Industry?
    let lastName: String?
    let mobileNumber: String?
    let occupation: User.Occupation?
    let registerSteps: [User.RegisterStep]
    let tfn: String?
    let taxResidency: String?
    let foreignTax: Bool?
    let tin: String?
    
}
