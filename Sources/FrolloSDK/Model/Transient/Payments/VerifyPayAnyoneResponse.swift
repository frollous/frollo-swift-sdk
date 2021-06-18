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
 VerifyPayAnyoneResponse
 
 Represents the response of verify pay anyone
 */
public struct VerifyPayAnyoneResponse: Codable {

    /// Address of the Bank
    public struct BSBAdress: Codable, Equatable {
        
        enum CodingKeys: String, CodingKey {
            case street
            case suburb
            case state
            case postcode = "postal_code"
        }
        
        /// The street of the bank address
        public let street: String?
        
        /// The suburb of the bank address
        public let suburb: String?

        /// The state of the bank address
        public let state: String?

        /// The postcode of the bank address
        public let postcode: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case valid
        case bsb
        case institutionMnemonic = "mnemonic"
        case bsbName = "name"
        case address
        case isNPPAllowed = "npp_allowed"
        case accountNumber = "account_number"
        case accountHolder = "account_holder"
    }
    
    /// True if the lookup was successful, false otherwise
    public let valid: Bool
    
    /// BSB number if BSB is valid, nil otherwise (Optional)
    public let bsb: String?
    
    /// institution mnemonic if BSB is valid, nil otherwise (Optional)
    public let institutionMnemonic: String?
    
    /// BSB name if BSB is valid, nil otherwise (Optional)
    public let bsbName: String?
    
    /// Address of the bank if BSB is valid, nil otherwise (Optional)
    public let address: BSBAdress?
    
    /// Indicates if NPP is supported by the bank. (Optional)
    public let isNPPAllowed: Bool?
    
    /// Account number if valid, nil otherwise (Optional)
    public let accountNumber: String?
    
    /// Account holder name if valid, nil otherwise (Optional)
    public let accountHolder: String?
    
}
