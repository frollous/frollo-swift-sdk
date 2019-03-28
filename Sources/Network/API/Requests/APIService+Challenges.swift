//
//  Copyright © 2018 Frollo. All rights reserved.
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
    
    internal func fetchChallenges(completion: @escaping RequestCompletion<[APIChallengeResponse]>) {
        requestQueue.async {
            let url = URL(string: ChallengesEndpoint.challenges.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIChallengeResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchChallenge(challengeID: Int64, completion: @escaping RequestCompletion<APIChallengeResponse>) {
        requestQueue.async {
            let url = URL(string: ChallengesEndpoint.challenge(challengeID: challengeID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIChallengeResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
