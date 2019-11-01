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

import Alamofire

extension APIService {
    
    // MARK: - Providers
    
    internal func fetchProviders(completion: @escaping RequestCompletion<[APIProviderResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providers.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIProviderResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProvider(providerID: Int64, completion: @escaping RequestCompletion<APIProviderResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.provider(providerID: providerID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIProviderResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Provider Accounts
    
    internal func fetchProviderAccounts(completion: @escaping RequestCompletion<[APIProviderAccountResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccounts.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIProviderAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProviderAccount(providerAccountID: Int64, completion: @escaping RequestCompletion<APIProviderAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIProviderAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func createProviderAccount(request: APIProviderAccountCreateRequest, completion: @escaping RequestCompletion<APIProviderAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccounts.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIProviderAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteProviderAccount(providerAccountID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateProviderAccount(providerAccountID: Int64, request: APIProviderAccountUpdateRequest, completion: @escaping RequestCompletion<APIProviderAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIProviderAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Accounts
    
    internal func fetchAccounts(completion: @escaping RequestCompletion<[APIAccountResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.accounts.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchAccount(accountID: Int64, completion: @escaping RequestCompletion<APIAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.account(accountID: accountID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateAccount(accountID: Int64, request: APIAccountUpdateRequest, completion: @escaping RequestCompletion<APIAccountResponse>) {
        requestQueue.async {
            guard request.valid
            else {
                let error = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(error))
                return
            }
            
            let url = URL(string: AggregationEndpoint.account(accountID: accountID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.network.handleResponse(type: APIAccountResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transactions
    
    internal func fetchTransactions(from fromDate: Date, to toDate: Date, count: Int, skip: Int, completion: @escaping RequestCompletion<[APITransactionResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactions.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Transaction.transactionDateFormatter
            
            let parameters = [AggregationEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              AggregationEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate),
                              AggregationEndpoint.QueryParameters.count.rawValue: String(count),
                              AggregationEndpoint.QueryParameters.skip.rawValue: String(skip)]
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APITransactionResponse.self, errorType: APIError.self, response: response, dateDecodingStrategy: .formatted(Transaction.transactionDateFormatter), completion: completion)
            }
        }
    }
    
    internal func fetchTransaction(transactionID: Int64, completion: @escaping RequestCompletion<APITransactionResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transaction(transactionID: transactionID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APITransactionResponse.self, errorType: APIError.self, response: response, dateDecodingStrategy: .formatted(Transaction.transactionDateFormatter), completion: completion)
            }
        }
    }
    
    internal func fetchTransactions(transactionIDs: [Int64], completion: @escaping RequestCompletion<[APITransactionResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactionsByID(transactionIDs: transactionIDs).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APITransactionResponse.self, errorType: APIError.self, response: response, dateDecodingStrategy: .formatted(Transaction.transactionDateFormatter), completion: completion)
            }
        }
    }
    
    internal func updateTransaction(transactionID: Int64, request: APITransactionUpdateRequest, completion: @escaping RequestCompletion<APITransactionResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transaction(transactionID: transactionID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.network.handleResponse(type: APITransactionResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func transactionSearch(searchTerm: String, count: Int, skip: Int, from fromDate: Date? = nil, to toDate: Date? = nil, accountIDs: [Int64]? = nil, onlyIncludedAccounts: Bool? = nil, completion: @escaping RequestCompletion<[APITransactionResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactionSearch.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Transaction.transactionDateFormatter
            
            var parameters = [AggregationEndpoint.QueryParameters.searchTerm.rawValue: searchTerm, AggregationEndpoint.QueryParameters.count.rawValue: String(count), AggregationEndpoint.QueryParameters.skip.rawValue: String(skip)]
            
            if let from = fromDate {
                parameters[AggregationEndpoint.QueryParameters.fromDate.rawValue] = dateFormatter.string(from: from)
            }
            
            if let to = toDate {
                parameters[AggregationEndpoint.QueryParameters.toDate.rawValue] = dateFormatter.string(from: to)
            }
            
            if let ids = accountIDs {
                parameters[AggregationEndpoint.QueryParameters.accountIDs.rawValue] = ids.map { String($0) }.joined(separator: ",")
            }
            
            if let included = onlyIncludedAccounts {
                parameters[AggregationEndpoint.QueryParameters.accountIncluded.rawValue] = included ? "true" : "false"
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APITransactionResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func transactionSummary(from fromDate: Date? = nil, to toDate: Date? = nil, accountIDs: [Int64]? = nil, transactionIDs: [Int64]? = nil, onlyIncludedAccounts: Bool? = nil, onlyIncludedTransactions: Bool? = nil, completion: @escaping RequestCompletion<APITransactionSummaryResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactionSummary.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Transaction.transactionDateFormatter
            
            var parameters = [String: String]()
            
            if let from = fromDate, let to = toDate {
                parameters[AggregationEndpoint.QueryParameters.fromDate.rawValue] = dateFormatter.string(from: from)
                parameters[AggregationEndpoint.QueryParameters.toDate.rawValue] = dateFormatter.string(from: to)
            }
            
            if let ids = accountIDs {
                parameters[AggregationEndpoint.QueryParameters.accountIDs.rawValue] = ids.map { String($0) }.joined(separator: ",")
            }
            
            if let ids = transactionIDs {
                parameters[AggregationEndpoint.QueryParameters.transactionIDs.rawValue] = ids.map { String($0) }.joined(separator: ",")
            }
            
            if let included = onlyIncludedAccounts {
                parameters[AggregationEndpoint.QueryParameters.accountIncluded.rawValue] = included ? "true" : "false"
            }
            
            if let included = onlyIncludedTransactions {
                parameters[AggregationEndpoint.QueryParameters.transactionIncluded.rawValue] = included ? "true" : "false"
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APITransactionSummaryResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transaction Categories
    
    internal func fetchTransactionCategories(completion: @escaping RequestCompletion<[APITransactionCategoryResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactionCategories.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APITransactionCategoryResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transaction Tags
    
    private enum TagType {
        case user
        case suggested
    }
    
    private func fetchTags(type: TagType, searchTerm: String? = nil, sort: Aggregation.SortType = .name, order: Aggregation.OrderType = .asc, completion: @escaping RequestCompletion<[APITransactionTagResponse]>) {
        var url: URL
        switch type {
            case .user:
                url = URL(string: AggregationEndpoint.transactionUserTags.path, relativeTo: serverURL)!
            case .suggested:
                url = URL(string: AggregationEndpoint.transactionSuggestedTags.path, relativeTo: serverURL)!
        }
        
        var parameters: [String: String] = [:]
        parameters[AggregationEndpoint.QueryParameters.searchTerm.rawValue] = searchTerm
        parameters[AggregationEndpoint.QueryParameters.sort.rawValue] = sort.rawValue
        parameters[AggregationEndpoint.QueryParameters.order.rawValue] = order.rawValue
        
        requestQueue.async {
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APITransactionTagResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateTags(transactionID: Int64, method: HTTPMethod, requestArray: [APITagUpdateRequest], completion: @escaping NetworkCompletion) {
        
        let url = URL(string: AggregationEndpoint.transactionTags(transactionID: transactionID).path, relativeTo: serverURL)!
        
        guard let urlRequest = self.network.contentRequest(url: url, method: method, content: requestArray)
        else {
            let dataError = DataError(type: .api, subType: .invalidData)
            
            completion(.failure(dataError))
            return
        }
        
        network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: responseQueue) { response in
            
            self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
        }
        
    }
    
    internal func listTagsForTransactrion(transactionID: Int64, completion: @escaping RequestCompletion<[APITagResponse]>) {
        
        let url = URL(string: AggregationEndpoint.transactionTags(transactionID: transactionID).path, relativeTo: serverURL)!
        
        requestQueue.async {
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APITagResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
        
    }
    
    internal func fetchTransactionSuggestedTags(searchTerm: String, sort: Aggregation.SortType = .name, order: Aggregation.OrderType = .asc, completion: @escaping RequestCompletion<[APITransactionTagResponse]>) {
        fetchTags(type: .suggested, searchTerm: searchTerm, sort: sort, order: order, completion: completion)
    }
    
    internal func fetchTransactionUserTags(searchTerm: String? = nil, sort: Aggregation.SortType = .name, order: Aggregation.OrderType = .asc, completion: @escaping RequestCompletion<[APITransactionTagResponse]>) {
        fetchTags(type: .user, searchTerm: searchTerm, sort: sort, order: order, completion: completion)
    }
    
    // MARK: - Merchants
    
    internal func fetchMerchants(completion: @escaping RequestCompletion<[APIMerchantResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.merchants.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIMerchantResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchMerchant(merchantID: Int64, completion: @escaping RequestCompletion<APIMerchantResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.merchant(merchantID: merchantID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIMerchantResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchMerchants(merchantIDs: [Int64], completion: @escaping RequestCompletion<[APIMerchantResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.merchantsByID(merchantIDs: merchantIDs).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIMerchantResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
