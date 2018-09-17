//
//  Network+Aggregation.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    // MARK: - Providers
    
    internal func fetchProviders(completion: @escaping RequestCompletion<[APIProviderResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providers.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIProviderResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProvider(providerID: Int64, completion: @escaping RequestCompletion<APIProviderResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.provider(providerID: providerID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIProviderResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Provider Accounts
    
    internal func fetchProviderAccounts(completion: @escaping RequestCompletion<[APIProviderAccountResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccounts.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIProviderAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProviderAccount(providerAccountID: Int64, completion: @escaping RequestCompletion<APIProviderAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIProviderAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func createProviderAccount(request: APIProviderAccountCreateRequest, completion: @escaping RequestCompletion<APIProviderAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccounts.path, relativeTo: self.serverURL)!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            
            let encoder = JSONEncoder()
            
            do {
                let requestData = try encoder.encode(request)
                
                urlRequest.httpBody = requestData
            } catch {
                Log.error(error.localizedDescription)
                
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(nil, dataError)
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIProviderAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateProviderAccount(providerAccountID: Int64, request: APIProviderAccountUpdateRequest, completion: @escaping RequestCompletion<APIProviderAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path, relativeTo: self.serverURL)!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            
            let encoder = JSONEncoder()
            
            do {
                let requestData = try encoder.encode(request)
                
                urlRequest.httpBody = requestData
            } catch {
                Log.error(error.localizedDescription)
                
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(nil, dataError)
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIProviderAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Accounts
    
    internal func fetchAccounts(completion: @escaping RequestCompletion<[APIAccountResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.accounts.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchAccount(accountID: Int64, completion: @escaping RequestCompletion<APIAccountResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.account(accountID: accountID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateAccount(accountID: Int64, request: APIAccountUpdateRequest, completion: @escaping RequestCompletion<APIAccountResponse>) {
        requestQueue.async {
            guard request.valid
                else {
                    let error = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, error)
                    return
            }
            
            let url = URL(string: AggregationEndpoint.account(accountID: accountID).path, relativeTo: self.serverURL)!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            
            let encoder = JSONEncoder()
            
            do {
                let requestData = try encoder.encode(request)
                
                urlRequest.httpBody = requestData
            } catch {
                Log.error(error.localizedDescription)
                
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(nil, dataError)
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.handleResponse(type: APIAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transactions
    
    internal func fetchTransactions(from fromDate: Date, to toDate: Date, completion: @escaping RequestCompletion<[APITransactionResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactions.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Transaction.transactionDateFormatter
            
            let parameters = [AggregationEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              AggregationEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            self.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APITransactionResponse.self, response: response, dateDecodingStrategy: .formatted(Transaction.transactionDateFormatter), completion: completion)
            }
        }
    }
    
    internal func fetchTransaction(transactionID: Int64, completion: @escaping RequestCompletion<APITransactionResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transaction(transactionID: transactionID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APITransactionResponse.self, response: response, dateDecodingStrategy: .formatted(Transaction.transactionDateFormatter), completion: completion)
            }
        }
    }
    
    internal func updateTransaction(transactionID: Int64, request: APITransactionUpdateRequest, completion: @escaping RequestCompletion<APITransactionResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transaction(transactionID: transactionID).path, relativeTo: self.serverURL)!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            
            let encoder = JSONEncoder()
            
            do {
                let requestData = try encoder.encode(request)
                
                urlRequest.httpBody = requestData
            } catch {
                Log.error(error.localizedDescription)
                
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(nil, dataError)
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.handleResponse(type: APITransactionResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transaction Categories
    
    internal func fetchTransactionCategories(completion: @escaping RequestCompletion<[APITransactionCategoryResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.transactionCategories.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APITransactionCategoryResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Merchants
    
    internal func fetchMerchants(completion: @escaping RequestCompletion<[APIMerchantResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.merchants.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIMerchantResponse.self, response: response, completion: completion)
            }
        }
    }
    
}
