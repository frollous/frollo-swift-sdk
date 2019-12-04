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
                parameters[BudgetsEndpoint.QueryParameters.current.rawValue] = currentParameter
            }
            
            if let budgetType = budgetType {
                parameters[BudgetsEndpoint.QueryParameters.categoryType.rawValue] = budgetType
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIBudgetResponse.self, errorType: APIError.self, response: response, completion: completion)
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
    
    internal func fetchBudgetPeriods(budgetID: Int64, from fromDate: Date?, to toDate: Date?, completion: @escaping RequestCompletion<[APIBudgetPeriodResponse]>) {
        requestQueue.async {
            let url = URL(string: BudgetsEndpoint.periods(budgetID: budgetID).path, relativeTo: self.serverURL)!
            
            let dateFormatter = Budget.budgetDateFormatter
            var parameters: Parameters = [:]
            
            if let fromDate = fromDate {
                parameters[BudgetsEndpoint.QueryParameters.fromDate.rawValue] = dateFormatter.string(from: fromDate)
            }
            
            if let toDate = toDate {
                parameters[BudgetsEndpoint.QueryParameters.toDate.rawValue] = dateFormatter.string(from: toDate)
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleArrayResponse(type: APIBudgetPeriodResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
