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

import Alamofire
import Foundation

extension APIService {
    func fetchAddresses(completion: @escaping RequestCompletion<[APIAddressResponse]>) {
        requestQueue.async {
            let url = URL(string: AddressEndpoint.addresses.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIAddressResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    func fetchAddress(addressID: Int64, completion: @escaping RequestCompletion<APIAddressResponse>) {
        requestQueue.async {
            let url = URL(string: AddressEndpoint.address(id: addressID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIAddressResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func createAddress(request: APIPostAddressRequest, completion: @escaping RequestCompletion<APIAddressResponse>) {
        requestQueue.async {
            let url = URL(string: AddressEndpoint.addresses.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIAddressResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func addressAutocomplete(query: String, max: Int, completion: @escaping RequestCompletion<[AddressAutocomplete]>) {
        requestQueue.async {
            let url = URL(string: AddressEndpoint.addressesAutocomplete.path, relativeTo: self.serverURL)!
            
            let parameters = [UserEndpoint.QueryParameters.query.rawValue: query, UserEndpoint.QueryParameters.max.rawValue: String(max)]
            
            self.network.sessionManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: AddressAutocomplete.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func getAddress(addressID: String, completion: @escaping RequestCompletion<APIAddressAutocompleteResopnse>) {
        requestQueue.async {
            let url = URL(string: AddressEndpoint.addressAutocomplete(addressID: addressID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIAddressAutocompleteResopnse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
}
