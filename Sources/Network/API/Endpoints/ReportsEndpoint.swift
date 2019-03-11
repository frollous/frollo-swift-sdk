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

internal enum ReportsEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case accountID = "account_id"
        case budgetCategory = "budget_category"
        case container
        case fromDate = "from_date"
        case grouping
        case period
        case toDate = "to_date"
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case accountBalance
    case transactionsCurrent
    case transactionsHistory
    
    private func urlPath() -> String {
        switch self {
            case .accountBalance:
                return "reports/accounts/history/balances"
            case .transactionsCurrent:
                return "reports/transactions/current"
            case .transactionsHistory:
                return "reports/transactions/history"
        }
    }
    
}
