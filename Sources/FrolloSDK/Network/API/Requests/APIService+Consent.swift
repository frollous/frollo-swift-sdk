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
    
    internal func fetchConsents(completion: @escaping RequestCompletion<[APICDRConsentResponse]>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.consents.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APICDRConsentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchConsent(consentID: Int64, completion: @escaping RequestCompletion<APICDRConsentResponse>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.consents(id: consentID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICDRConsentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func submitConsent(request: APICDRConsentCreateRequest, completion: @escaping RequestCompletion<APICDRConsentResponse>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.consents(id: nil).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICDRConsentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateConsent(consentID: Int64, request: APICDRConsentUpdateRequest, completion: @escaping RequestCompletion<APICDRConsentResponse>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.consents(id: consentID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICDRConsentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchProducts(accountID: Int64, completion: @escaping RequestCompletion<[CDRProduct]>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.products.path, relativeTo: self.serverURL)!
            
            let parameters = [CDREndpoint.QueryParameters.accountID.rawValue: accountID]
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: CDRProduct.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchCDRConfiguration(completion: @escaping RequestCompletion<APICDRConfigurationResponse>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.configuration.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICDRConfigurationResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
}
