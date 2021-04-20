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

enum BudgetsEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case current
        case categoryType = "category_type"
        case fromDate = "from_date"
        case toDate = "to_date"
        case status
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case budget(budgetID: Int64)
    case budgets
    case period(budgetID: Int64, budgetPeriodID: Int64)
    case periods(budgetID: Int64? = nil)
    
    private func urlPath() -> String {
        switch self {
            case .budget(let budgetID):
                return "budgets/" + String(budgetID)
            case .budgets:
                return "budgets"
            case .period(let budgetID, let budgetPeriodID):
                return "budgets/" + String(budgetID) + "/periods/" + String(budgetPeriodID)
            case .periods(let budgetID):
                guard let budgetID = budgetID else {
                    return "budgets/periods"
                }
                return "budgets/" + String(budgetID) + "/periods"
        }
    }
    
}
