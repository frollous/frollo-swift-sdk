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

import Foundation

class OAuthService {
    
    internal let authorizationURL: URL
    internal let network: Network
    internal let redirectURL: URL
    internal let tokenURL: URL
    
    /// Asynchronous queue all network requests are executed from
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    
    /// Asynchornous queue all network responses are executed on
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    
    init(authorizationEndpoint: URL, tokenEndpoint: URL, redirectURL: URL, network: Network) {
        self.authorizationURL = authorizationEndpoint
        self.network = network
        self.redirectURL = redirectURL
        self.tokenURL = tokenEndpoint
    }
    
    internal func refreshTokens(request: OAuthTokenRequest, completion: @escaping RequestCompletion<OAuthTokenResponse>) {
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
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(errorType: .OAuth2, type: OAuthTokenResponse.self, response: response, dateDecodingStrategy: .secondsSince1970, completion: completion)
            }
        }
    }
    
}
