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
 VerifyBPAYResponse
 
 Represents the response of verify pay id
 */
public struct VerifyBPAYResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case valid
        case billerCode = "biller_code"
        case billerName = "biller_name"
        case crn
        case billerMinAmount = "biller_min_amount"
        case billerMaxAmount = "biller_max_amount"
    }
    
    /// The validity of the biller
    public let valid: Bool
    
    /// The code of the biller
    public let billerCode: String
    
    /// The name of the biller
    public let billerName: String?
    
    /// The CRN of the biller
    public let crn: String?
    
    /// The minimum payment amount of this biller
    public let billerMinAmount: String?
    
    /// The maximum payment amount of this biller
    public let billerMaxAmount: String?
}
