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
    
    // MARK: - Goals
    
    internal func fetchGoal(goalID: Int64, completion: @escaping RequestCompletion<APIGoalResponse>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.goal(goalID: goalID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIGoalResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchGoals(status: Goal.Status? = nil, trackingStatus: Goal.TrackingStatus? = nil, completion: @escaping RequestCompletion<[APIGoalResponse]>) {
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
    
    internal func createGoal(request: APIGoalCreateRequest, completion: @escaping RequestCompletion<APIGoalResponse>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.goals.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIGoalResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteGoal(goalID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.goal(goalID: goalID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue, emptyResponseCodes: [204]) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateGoal(goalID: Int64, request: APIGoalUpdateRequest, completion: @escaping RequestCompletion<APIGoalResponse>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.goal(goalID: goalID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIGoalResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Goal Periods
    
    internal func fetchGoalPeriod(goalID: Int64, goalPeriodID: Int64, completion: @escaping RequestCompletion<APIGoalPeriodResponse>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.period(goalID: goalID, goalPeriodID: goalPeriodID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIGoalPeriodResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchGoalPeriods(goalID: Int64, completion: @escaping RequestCompletion<[APIGoalPeriodResponse]>) {
        requestQueue.async {
            let url = URL(string: GoalsEndpoint.periods(goalID: goalID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIGoalPeriodResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
