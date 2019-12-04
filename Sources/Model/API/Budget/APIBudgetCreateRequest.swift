//
//  Copyright © 2018 Frollo. All rights reserved.
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
import SwiftyJSON

struct APIBudgetCreateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case frequency
        case periodAmount = "period_amount"
        case targetAmount = "target_amount"
        case type
        case typeValue = "type_value"
    }
    
    let frequency: Budget.Frequency
    let periodAmount: String?
    let targetAmount: String?
    let type: Budget.BudgetType
    let typeValue: String
    
    internal func valid() -> Bool {
        return targetAmount != nil && periodAmount != nil && !typeValue.isEmpty
    }
    
}
