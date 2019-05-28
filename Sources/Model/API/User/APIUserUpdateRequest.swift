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
    let primaryCurrency: String
    
    let address: Address?
    let attribution: Attribution?
    let dateOfBirth: Date?
    let firstName: String?
    let gender: User.Gender?
    let householdSize: Int64?
    let householdType: User.HouseholdType?
    let industry: User.Industry?
    let lastName: String?
    let mobileNumber: String?
    let occupation: User.Occupation?
    
}
