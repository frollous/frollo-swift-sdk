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
    
    typealias ProviderRequestCompletion = (_: APIProviderResponse?, _: Error?) -> Void
    typealias ProvidersRequestCompletion = (_: [APIProviderResponse]?, _: Error?) -> Void
    
    internal func fetchProvider(providerID: Int64, completion: @escaping ProviderRequestCompletion) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.provider(providerID: providerID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.handleProviderResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProviders(completion: @escaping ProvidersRequestCompletion) {
        requestQueue.async {
            let url = URL(string: AggregationEndpoint.providers.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
                self.handleProvidersResponse(response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleProviderResponse(response: DataResponse<Data>, completion: ProviderRequestCompletion) {
        switch response.result {
        case .success(let value):
            let decoder = JSONDecoder()
            do {
                let providerResponse = try decoder.decode(APIProviderResponse.self, from: value)
                
                completion(providerResponse, nil)
            } catch {
                Log.error(error.localizedDescription)
                
                let dataError = DataError(type: .unknown, subType: .unknown)
                completion(nil, dataError)
            }
        case .failure:
            self.handleFailure(response: response) { (error) in
                completion(nil, error)
            }
        }
    }
    
    private func handleProvidersResponse(response: DataResponse<Data>, completion: ProvidersRequestCompletion) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                do {
                    let providersResponse = try decoder.decode(FailableCodableArray<APIProviderResponse>.self, from: value)
                    
                    completion(providersResponse.elements, nil)
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .unknown, subType: .unknown)
                    completion(nil, dataError)
                }
            case .failure:
                self.handleFailure(response: response) { (error) in
                    completion(nil, error)
                }
        }
    }
    
}
