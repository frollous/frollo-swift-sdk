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

enum AggregationEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case accountIDs = "account_ids"
        case accountIncluded = "account_included"
        case count
        case fromDate = "from_date"
        case searchTerm = "search_term"
        case skip
        case toDate = "to_date"
        case transactionIDs = "transaction_ids"
        case transactionIncluded = "transaction_included"
        case sort
        case order
    }
    
    enum OrderType: String {
        case asc
        case desc
    }
    
    enum SortType: String {
        case name
        case relevance
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case account(accountID: Int64)
    case accounts
    case merchant(merchantID: Int64)
    case merchants
    case merchantsByID(merchantIDs: [Int64])
    case provider(providerID: Int64)
    case providers
    case providerAccount(providerAccountID: Int64)
    case providerAccounts
    case transaction(transactionID: Int64)
    case transactions
    case transactionsByID(transactionIDs: [Int64])
    case transactionCategories
    case transactionSearch
    case transactionSummary
    case transactionSuggestedTags
    
    private func urlPath() -> String {
        switch self {
            case .account(let accountID):
                return "aggregation/accounts/" + String(accountID)
            case .accounts:
                return "aggregation/accounts"
            case .merchant(let merchantID):
                return "aggregation/merchants/" + String(merchantID)
            case .merchants:
                return "aggregation/merchants"
            case .merchantsByID(let merchantIDs):
                return "aggregation/merchants?merchant_ids=" + merchantIDs.map { String($0) }.joined(separator: ",")
            case .provider(let providerID):
                return "aggregation/providers/" + String(providerID)
            case .providers:
                return "aggregation/providers"
            case .providerAccount(let providerAccountID):
                return "aggregation/provideraccounts/" + String(providerAccountID)
            case .providerAccounts:
                return "aggregation/provideraccounts"
            case .transaction(let transactionID):
                return "aggregation/transactions/" + String(transactionID)
            case .transactions:
                return "aggregation/transactions"
            case .transactionsByID(let transactionIDs):
                return "aggregation/transactions?transaction_ids=" + transactionIDs.map { String($0) }.joined(separator: ",")
            case .transactionCategories:
                return "aggregation/transactions/categories"
            case .transactionSearch:
                return "aggregation/transactions/search"
            case .transactionSummary:
                return "aggregation/transactions/summary"
            case .transactionSuggestedTags:
                return "aggregation/transactions/tags/suggested"
        }
    }
    
}
