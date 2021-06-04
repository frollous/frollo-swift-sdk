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
 VerifyBSBResponse
 
 Represents the response of verify BSB
 */
public struct VerifyBSBResponse: Codable {
    
    /// bsb
    public let bsb: String
    
    /// institution mnemonic
    public let institutionMnemonic: String
    
    /// name of the bank
    public let name: String
    
    /// Address of the bank
    public let streetAddress: String
    
    /// Suburb of the bank
    public let suburb: String
    
    /// State of the bank
    public let state: String
    
    /// Post code of the bank
    public let postCode: String
    
    /// Value of NPP, is it allowed or not
    public let isNPPAllowed: Bool
    
    enum CodingKeys: String, CodingKey {
        case bsb
        case institutionMnemonic = "institution_mnemonic"
        case name
        case streetAddress = "street_address"
        case suburb
        case state
        case postCode = "postcode"
        case isNPPAllowed = "is_npp_allowed"
    }
}
