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
    
    enum CodingKeys: String, CodingKey {
        case bsb
        case bsbName = "bsb_name"
        case accountNumber = "account_number"
        case accountHolder = "account_holder"
        case valid
    }
    
    /// BSB number if valid is true nil otherwise (Optional)
    public let bsb: String?
    
    /// BSB name if valid is true nil otherwise (Optional)
    public let bsbName: String?
    
    /// Account number if valid is true nil otherwise (Optional)
    public let accountNumber: String?
    
    /// Account holder name if valid is true nil otherwise (Optional)
    public let accountHolder: String?
    
    /// True if the lookup is valid, false otherwise
    public let valid: Bool
    
}
