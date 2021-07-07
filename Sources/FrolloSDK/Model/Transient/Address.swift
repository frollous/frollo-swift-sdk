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

/**
 Address
 
 Represents response of Address Autocomplete
 */
public struct APIAddressAutocompleteResopnse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case buildingName = "building_name"
        case country
        case longForm = "long_form"
        case postcode = "postal_code"
        case region
        case state
        case streetName = "street_name"
        case streetNumber = "street_number"
        case streetType = "street_type"
        case suburb
        case town
        case unitNumber = "unit_number"
    }
    
    /**
     Initilizer
     
     - Parameters:
       - buildingName: building name. (Optional)
       - unitNumber: unit number. (Optional)
       - streetNumber: street number. (Optional)
       - streetName: street name. (Optional)
       - streetType: street type. (Optional)
       - suburb: suburb. (Optional)
       - town: town. (Optional)
       - region: region. (Optional)
       - state: state. (Optional)
       - country: country.
       - postcode: post code. (Optional)
       - longForm: long form. (Optional)
     */
    
    public init(buildingName: String? = nil, unitNumber: String? = nil, streetNumber: String? = nil, streetName: String? = nil, streetType: String? = nil, suburb: String? = nil, town: String? = nil, region: String? = nil, state: String? = nil, country: String, postcode: String? = nil, longForm: String? = nil) {
        
        self.buildingName = buildingName
        self.unitNumber = unitNumber
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.streetType = streetType
        self.suburb = suburb
        self.town = town
        self.region = region
        self.state = state
        self.country = country
        self.postcode = postcode
        self.longForm = longForm
    }
    
    /// Address building name. (Optional)
    public var buildingName: String?
    
    /// Address unit number. (Optional)
    public var unitNumber: String?
    
    /// Address street number. (Optional)
    public var streetNumber: String?
    
    /// Address street name. (Optional)
    public var streetName: String?
    
    /// Address street type. (Optional)
    public var streetType: String?
    
    /// Address suburb name. (Optional)
    public var suburb: String?
    
    /// Address town name. (Optional)
    public var town: String?
    
    /// Address region. (Optional)
    public var region: String?
    
    /// Address state. (Optional)
    public var state: String?
    
    /// Address country.
    public var country: String
    
    /// Address post code. (Optional)
    public var postcode: String?
    
    /// Full address in formatted form. (Optional)
    public let longForm: String?
    
}
