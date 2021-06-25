//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

struct APIAddressResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case buildingName = "building_name"
        case unitNumber = "unit_number"
        case streetNumber = "street_number"
        case streetName = "street_name"
        case streetType = "street_type"
        case suburb
        case town
        case region
        case state
        case country
        case postcode = "postal_code"
        case longForm = "long_form"
    }
    
    var id: Int64
    let buildingName: String?
    let unitNumber: String?
    let streetNumber: String?
    let streetName: String?
    let streetType: String?
    let suburb: String?
    let town: String?
    let region: String?
    let state: String?
    let country: String
    let postcode: String?
    let longForm: String?
}
