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

import Alamofire
import Foundation

extension APIService {
    
    internal func fetchBudgets(current: Bool? = true, category: String? = nil, completion: @escaping RequestCompletion<[APIGoalResponse]>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.goals.path, relativeTo: self.serverURL)!
            
            var parameters = [String: Any]()
            
            if let statusParameter = current {
                parameters[BudgetsEndpoint.QueryParameters.current.rawValue] = statusParameter
            }
            
            if let category = category {
                parameters[BudgetsEndpoint.QueryParameters.categoryType.rawValue] = category
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIGoalResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
