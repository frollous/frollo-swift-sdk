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

struct APITransactionCategoryResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case categoryType = "category_type"
        case defaultBudgetCategory = "default_budget_category"
        case iconURL = "icon_url"
        case id
        case name
        case placement
        case userDefined = "user_defined"
    }
    
    var id: Int64
    let categoryType: TransactionCategory.CategoryType
    let defaultBudgetCategory: BudgetCategory
    let iconURL: String
    let name: String
    let placement: Int64
    let userDefined: Bool
    
}
