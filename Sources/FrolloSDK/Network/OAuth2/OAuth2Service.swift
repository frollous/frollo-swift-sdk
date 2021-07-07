//
// Copyright © 2019 Frollo. All rights reserved.
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

import Alamofire
import Foundation

class OAuth2Service {
    
    internal let authorizationURL: URL
    internal let network: Network
    internal let redirectURL: URL
    internal let revokeURL: URL?
    internal let tokenURL: URL
    internal let sessionManager: Session
    
    /// Asynchronous queue all network requests are executed from
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    
    /// Asynchornous queue all network responses are executed on
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    
    init(authorizationEndpoint: URL, tokenEndpoint: URL, redirectURL: URL, revokeURL: URL?, network: Network) {
        self.authorizationURL = authorizationEndpoint
        self.network = network
        self.redirectURL = redirectURL
        self.revokeURL = revokeURL
        self.tokenURL = tokenEndpoint
        
        let configuration = self.network.sessionManager.sessionConfiguration
        let trustManager = self.network.sessionManager.serverTrustManager
        let interceptor = self.network.sessionManager.interceptor
        
        // Create a new session without the session delegate because it's causing dispatch queue issues in Alamofire
        self.sessionManager = Session(configuration: configuration, interceptor: interceptor, serverTrustManager: trustManager)
    }
    
    internal func refreshTokens(request: OAuth2TokenRequest, completion: @escaping RequestCompletion<OAuth2TokenResponse>) {
        requestQueue.async {
            guard request.valid
            else {
                let error = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(error))
                return
            }
            
            guard let urlRequest = self.network.contentRequest(url: self.tokenURL, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: OAuth2TokenResponse.self, errorType: OAuth2Error.self, response: response, dateDecodingStrategy: .secondsSince1970, completion: completion)
            }
        }
    }
    
    internal func revokeToken(request: OAuth2TokenRevokeRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            guard let revokeTokenURL = self.revokeURL
            else {
                let error = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(error))
                
                return
            }
            
            guard let urlRequest = self.network.contentRequest(url: revokeTokenURL, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue, emptyResponseCodes: [200]) { response in
                self.network.handleEmptyResponse(errorType: OAuth2Error.self, response: response, completion: completion)
            }
        }
    }
    
}
