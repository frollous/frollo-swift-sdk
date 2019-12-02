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
    
    internal func fetchBudgets(status: Goal.Status? = nil, trackingStatus: Goal.TrackingStatus? = nil, completion: @escaping RequestCompletion<[APIGoalResponse]>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.goals.path, relativeTo: self.serverURL)!
            
            var parameters = [String: String]()
            
            if let statusParameter = status {
                parameters[GoalsEndpoint.QueryParameters.status.rawValue] = statusParameter.rawValue
            }
            if let trackingStatusParameter = trackingStatus {
                parameters[GoalsEndpoint.QueryParameters.trackingStatus.rawValue] = trackingStatusParameter.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIGoalResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
