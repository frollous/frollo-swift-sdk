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
    
    internal func fetchProvider(providerID: Int64, completion: @escaping RequestCompletion<APIProviderResponse>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.provider(providerID: providerID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIProviderResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProviders(completion: @escaping RequestCompletion<[APIProviderResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providers.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIProviderResponse.self, response: response, completion: completion)
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
    
    internal func fetchProviderAccounts(completion: @escaping RequestCompletion<[APIProviderAccountResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providerAccounts.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIProviderAccountResponse.self, response: response, completion: completion)
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
    
    internal func fetchAccounts(completion: @escaping RequestCompletion<[APIAccountResponse]>) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.accounts.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIAccountResponse.self, response: response, completion: completion)
            }
        }
    }
    
}
