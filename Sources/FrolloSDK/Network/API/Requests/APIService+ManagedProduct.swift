//
//  Copyright © 2019 Frollo. All rights reserved.
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

import Alamofire
import Foundation

extension APIService {
    
    internal func listAvailableProducts(before: String? = nil, after: String? = nil, size: Int? = nil, completion: @escaping RequestCompletion<APIPaginatedResponse<ManagedProduct>>) {
        requestQueue.async {
            
            let url = URL(string: ManagedProductEndpoint.availableProducts.path, relativeTo: self.serverURL)!
            
            var parameters = [String: String]()
            
            if let before = before {
                parameters[ManagedProductEndpoint.QueryParameters.before.rawValue] = before
            }
            if let after = after {
                parameters[ManagedProductEndpoint.QueryParameters.after.rawValue] = after
            }
            if let size = size {
                parameters[ManagedProductEndpoint.QueryParameters.size.rawValue] = String(size)
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handlePaginatedArrayResponse(type: ManagedProduct.self, errorType: APIError.self, response: response, completion: completion)
                
            }
        }
    }
    
    internal func listManagedProducts(before: String? = nil, after: String? = nil, size: Int? = nil, completion: @escaping RequestCompletion<APIPaginatedResponse<ManagedProduct>>) {
        requestQueue.async {
            
            let url = URL(string: ManagedProductEndpoint.managedProducts.path, relativeTo: self.serverURL)!
            
            var parameters = [String: String]()
            
            if let before = before {
                parameters[ManagedProductEndpoint.QueryParameters.before.rawValue] = before
            }
            if let after = after {
                parameters[ManagedProductEndpoint.QueryParameters.after.rawValue] = after
            }
            if let size = size {
                parameters[ManagedProductEndpoint.QueryParameters.size.rawValue] = String(size)
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handlePaginatedArrayResponse(type: ManagedProduct.self, errorType: APIError.self, response: response, completion: completion)
                
            }
        }
    }
    
    internal func createManagedProduct(request: APIProductCreateRequest, completion: @escaping RequestCompletion<ManagedProduct>) {
        
        let url = URL(string: ManagedProductEndpoint.managedProducts.path, relativeTo: serverURL)!
        
        guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
        else {
            let dataError = DataError(type: .api, subType: .invalidData)
            
            completion(.failure(dataError))
            return
        }
        
        network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: responseQueue) { response in
            self.network.handleResponse(type: ManagedProduct.self, errorType: APIError.self, response: response, completion: completion)
        }
        
    }
    
    internal func deleteManagedProducts(productID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: ManagedProductEndpoint.product(productID: productID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue, emptyResponseCodes: [200]) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
                
            }
        }
    }
    
}
