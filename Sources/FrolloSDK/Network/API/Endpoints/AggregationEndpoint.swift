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
        case after
        case before
        case count
        case fromDate = "from_date"
        case searchTerm = "search_term"
        case size
        case skip
        case toDate = "to_date"
        case transactionIDs = "transaction_ids"
        case transactionIncluded = "transaction_included"
        case sort
        case order
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case account(accountID: Int64)
    case accountPaymentLimits(accountID: Int64)
    case accounts
    case merchant(merchantID: Int64)
    case merchants
    case merchantsByID(merchantIDs: [Int64])
    case provider(providerID: Int64)
    case providers
    case providerAccount(providerAccountID: Int64)
    case providerAccounts
    case syncProviderAccounts(providerAccountIDs: [Int64])
    case transaction(transactionID: Int64)
    case transactions(transactionFilter: TransactionFilter? = nil)
    case transactionCategories
    case transactionSearch
    case transactionSummary
    case transactionSuggestedTags
    case transactionUserTags
    case transactionTags(transactionID: Int64)
    
    private func urlPath() -> String {
        switch self {
            case .account(let accountID):
                return "aggregation/accounts/" + String(accountID)
            case .accountPaymentLimits(let accountID):
                return "aggregation/accounts/" + String(accountID) + "/limits"
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
            case .syncProviderAccounts(let providerAccountIDs):
                return "aggregation/provideraccounts?provideraccount_ids=" + providerAccountIDs.map { String($0) }.joined(separator: ",")
            case .transaction(let transactionID):
                return "aggregation/transactions/" + String(transactionID)
            case .transactions(let transactionFilter):
                return transactionFilter?.urlString ?? "aggregation/transactions"
            case .transactionCategories:
                return "aggregation/transactions/categories"
            case .transactionSearch:
                return "aggregation/transactions/search"
            case .transactionSummary:
                return "aggregation/transactions/summary"
            case .transactionSuggestedTags:
                return "aggregation/transactions/tags/suggested"
            case .transactionUserTags:
                return "aggregation/transactions/tags/user"
            case .transactionTags(let transactionID):
                return "aggregation/transactions/" + String(transactionID) + "/tags"
                
        }
    }
    
}
