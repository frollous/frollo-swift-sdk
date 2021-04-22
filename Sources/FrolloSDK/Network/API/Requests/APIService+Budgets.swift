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
    
    // MARK: - Budgets
    
    internal func fetchBudget(budgetID: Int64, completion: @escaping RequestCompletion<APIBudgetResponse>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.budget(budgetID: budgetID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBudgetResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBudgets(current: Bool? = true, budgetType: Budget.BudgetType? = nil, completion: @escaping RequestCompletion<[APIBudgetResponse]>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.budgets.path, relativeTo: self.serverURL)!
            
            var parameters = [String: Any]()
            
            if let currentParameter = current {
                parameters[BudgetsEndpoint.QueryParameters.current.rawValue] = currentParameter ? "true" : "false"
            }
            
            if let budgetType = budgetType {
                parameters[BudgetsEndpoint.QueryParameters.categoryType.rawValue] = budgetType
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIBudgetResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func createBudget(request: APIBudgetCreateRequest, completion: @escaping RequestCompletion<APIBudgetResponse>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.budgets.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBudgetResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteBudget(budgetID: Int64, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.budget(budgetID: budgetID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateBudget(budgetID: Int64, request: APIBudgetUpdateRequest, completion: @escaping RequestCompletion<APIBudgetResponse>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.budget(budgetID: budgetID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBudgetResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Budget Periods
    
    internal func fetchBudgetPeriod(budgetID: Int64, budgetPeriodID: Int64, completion: @escaping RequestCompletion<APIBudgetPeriodResponse>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.period(budgetID: budgetID, budgetPeriodID: budgetPeriodID).path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIBudgetPeriodResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchBudgetPeriods(before: String? = nil, after: String? = nil, size: Int? = nil, budgetID: Int64? = nil, from fromDate: Date?, to toDate: Date?, status: Budget.Status? = nil, completion: @escaping RequestCompletion<APIPaginatedResponse<APIBudgetPeriodResponse>>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.periods(budgetID: budgetID).path, relativeTo: self.serverURL)!
            
            let dateFormatter = Budget.budgetDateFormatter
            var parameters = [String: Any]()
            
            if let before = before {
                parameters[ContactsEndpoint.QueryParameters.before.rawValue] = before
            }
            
            if let after = after {
                parameters[ContactsEndpoint.QueryParameters.after.rawValue] = after
            }
            
            if let size = size {
                parameters[ContactsEndpoint.QueryParameters.size.rawValue] = String(size)
            }
            
            if let fromDate = fromDate {
                parameters[BudgetsEndpoint.QueryParameters.fromDate.rawValue] = dateFormatter.string(from: fromDate)
            }
            
            if let toDate = toDate {
                parameters[BudgetsEndpoint.QueryParameters.toDate.rawValue] = dateFormatter.string(from: toDate)
            }
            
            if let status = status {
                parameters[BudgetsEndpoint.QueryParameters.status.rawValue] = status.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handlePaginatedArrayResponse(type: APIBudgetPeriodResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
            
        }
    }
    
}
