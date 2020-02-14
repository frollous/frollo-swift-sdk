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
    
    func submitCDRConsent(request: APICDRConsentCreateRequest, completion: @escaping RequestCompletion<APICDRConsentResponse>) {
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
    
    func updateCDRConsent(id: Int64, request: APICDRConsentUpdateRequest, completion: @escaping RequestCompletion<APICDRConsentResponse>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.consents(id: id).path, relativeTo: self.serverURL)!
            
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
    
    func fetchCDRConsent(id: Int64, completion: @escaping RequestCompletion<APICDRConsentResponse>) {
        requestQueue.async {
            let url = URL(string: CDREndpoint.consents(id: id).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICDRConsentResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
}
