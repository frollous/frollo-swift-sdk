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

/**
 Budget Category
 
 Indicates a budget type
 */
public enum BudgetCategory: String, Codable, CaseIterable {
    
    /// Income budget
    case income
    
    /// Lifestyle budget
    case lifestyle
    
    /// Living budget
    case living
    
    /// One offs budget
    case oneOff = "one_off"
    
    /// Savings budget
    case savings = "goals"
    
    /// Initializes the BudgetCategory by its `id`
    public init?(id: Int64) {
        switch id {
            case 0:
                self = .income
            case 1:
                self = .living
            case 2:
                self = .lifestyle
            case 3:
                self = .savings
            case 4:
                self = .oneOff
            default:
                return nil
        }
    }
    
    /// Returns the `id` of the BudgetCategory
    public var id: Int64 {
        switch self {
            case .income:
                return 0
            case .living:
                return 1
            case .lifestyle:
                return 2
            case .savings:
                return 3
            case .oneOff:
                return 4
        }
    }
    
}

/// Defines all possible cases to filter on a specific entity
public enum TransactionReportFilter {
    
    /// Filter based on budget category. `id` argument defines whether to filter based on a specific budget category or based on all of them
    case budgetCategory(id: Int64?)
    
    /// Filter based on merchant. `id` argument defines whether to filter based on a specific merchant or based on all of them
    case merchant(id: Int64?)
    
    /// Filter based on category. `id` argument defines whether to filter based on a specific category or based on all of them
    case category(id: Int64?)
    
    /// Filter based on tag. `name` argument defines whether to filter based on a specific category or based on all of them
    case tag(name: String?)
    
    /// The entity name for each filter type based on the backend
    var entity: String {
        switch self {
            case .budgetCategory:
                return "budget_categories"
            case .merchant:
                return "merchants"
            case .category:
                return "categories"
            case .tag:
                return "tags"
        }
    }
    
    /// The id of the entity to filter on
    var id: String? {
        switch self {
            case .budgetCategory(let id), .category(let id), .merchant(let id):
                guard let id = id else { return nil }
                return "\(id)"
            case .tag(let name):
                return name
        }
    }
}
