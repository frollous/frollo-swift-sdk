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

extension APIService {
    
    internal func fetchContact(contactID: Int64, completion: @escaping RequestCompletion<APIContactResponse>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contact(contactID: contactID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchContacts(type: String? = nil, before: String? = nil, after: String? = nil, size: Int? = nil, completion: @escaping RequestCompletion<APIPaginatedResponse<APIContactResponse>>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contacts.path, relativeTo: self.serverURL)!
            
            var parameters = [String: String]()
            if let type = type {
                parameters[ContactsEndpoint.QueryParameters.type.rawValue] = type
            }
            if let before = before {
                parameters[ContactsEndpoint.QueryParameters.before.rawValue] = before
            }
            if let after = after {
                parameters[ContactsEndpoint.QueryParameters.after.rawValue] = after
            }
            if let size = size {
                parameters[ContactsEndpoint.QueryParameters.size.rawValue] = String(size)
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handlePaginatedArrayResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func createContact(request: APICreateContactRequest, completion: @escaping RequestCompletion<APIContactResponse>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contacts.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func createInternationalContact(request: APICreateInternationalContactRequest, completion: @escaping RequestCompletion<APIContactResponse>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contacts.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateContact(contactID: Int64, request: APICreateContactRequest, completion: @escaping RequestCompletion<APIContactResponse>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contact(contactID: contactID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateInternationalContact(contactID: Int64, request: APICreateInternationalContactRequest, completion: @escaping RequestCompletion<APIContactResponse>) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contact(contactID: contactID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIContactResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteContact(contactID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: ContactsEndpoint.contact(contactID: contactID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
}
