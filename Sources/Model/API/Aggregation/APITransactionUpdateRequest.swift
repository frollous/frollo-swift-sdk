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

struct APITransactionUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case budgetCategory = "budget_category"
        case categoryID = "category_id"
        case included
        case includeApplyAll = "include_apply_all"
        case memo
        case recategoriseAll = "recategorise_all"
        case userDescription = "user_description"
    }
    
    let budgetCategory: BudgetCategory
    let categoryID: Int64
    let included: Bool
    let memo: String?
    let userDescription: String?
    
    var includeApplyAll: Bool?
    var recategoriseAll: Bool?
    
}
