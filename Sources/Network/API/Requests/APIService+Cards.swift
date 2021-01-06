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
    
    internal func createCard(request: APICreateCardRequest, completion: @escaping RequestCompletion<APICardResponse>) {
        requestQueue.async {
            let url = URL(string: CardsEndpoint.cards.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICardResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    func fetchCards(completion: @escaping RequestCompletion<[APICardResponse]>) {
        requestQueue.async {
            let url = URL(string: CardsEndpoint.cards.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APICardResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    func fetchCard(cardID: Int64, completion: @escaping RequestCompletion<APICardResponse>) {
        requestQueue.async {
            let url = URL(string: CardsEndpoint.card(cardID: cardID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICardResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateCard(cardID: Int64, request: APIUpdateCardRequest, completion: @escaping RequestCompletion<APICardResponse>) {
        requestQueue.async {
            let url = URL(string: CardsEndpoint.card(cardID: cardID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APICardResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
