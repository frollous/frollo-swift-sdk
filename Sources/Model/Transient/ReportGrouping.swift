//
// Copyright © 2019 Frollo. All rights reserved.
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

/**
 Report Grouping
 
 Represents how a transaction report response should be broken down. E.g. by merchant
 */
public enum ReportGrouping: String, Codable, CaseIterable {
    
    /// Budget category
    case budgetCategory = "by_budget_category"
    
    /// Merchant
    case merchant = "by_merchant"
    
    /// Transaction Category
    case transactionCategory = "by_transaction_category"
    
    /// Transaction Category Parent Group
    case transactionCategoryGroup = "by_transaction_category_group"
    
    /// Tag group
    case tag = "by_tag"
    
}
