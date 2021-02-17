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

struct APIUserUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case attribution
        case address
        case dateOfBirth = "date_of_birth"
        case email
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
        case taxResidency = "tax_residency"
        case tfn
        case tin
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
    let primaryCurrency: String
    let address: Address?
    let mailingAddress: Address?
    let attribution: Attribution?
    let dateOfBirth: Date?
    let firstName: String?
    let foreignTax: Bool?
    let gender: User.Gender?
    let householdSize: Int64?
    let householdType: User.HouseholdType?
    let industry: User.Industry?
    let lastName: String?
    let mobileNumber: String?
    let occupation: User.Occupation?
    let taxResidency: String?
    let tfn: String?
    let tin: String?
}
