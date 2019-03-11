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

struct APIBillsResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case bills
        case budgetPeriod = "budget_period"
    }
    
    struct BudgetPeriod: Codable {
        
        enum CodingKeys: String, CodingKey {
            case amountPaid = "amount_paid"
            case amountRemaining = "amount_remaining"
        }
        
        let amountPaid: Int64
        let amountRemaining: Int64
        
    }
    
    let bills: [APIBillResponse]
    let budgetPeriod: BudgetPeriod
    
}
