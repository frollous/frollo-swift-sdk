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

class APIService {
    
    internal let network: Network
    internal let serverURL: URL
    
    /// Asynchronous queue all network requests are executed from
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    
    /// Asynchornous queue all network responses are executed on
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    
    init(serverEndpoint: URL, network: Network) {
        self.network = network
        self.serverURL = serverEndpoint
    }
    
    internal func downloadData(url: URL, completion: ((Swift.Result<Data, Error>) -> Void)?) {
        requestQueue.async { [weak self] in
            self?.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self?.responseQueue) { response in
                switch response.result {
                    case .success(let value):
                        completion?(.success(value))
                    case .failure(let error):
                        self?.network.handleFailure(type: APIError.self, response: response, error: error) { processedError in
                            completion?(.failure(processedError))
                        }
                }
            }
        }
    }
    
}
