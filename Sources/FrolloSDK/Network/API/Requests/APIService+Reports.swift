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

import Alamofire

extension APIService {
    
    // MARK: - Account Balance Reports
    
    internal func fetchAccountBalanceReports(period: ReportAccountBalance.Period, from fromDate: Date, to toDate: Date, accountID: Int64? = nil, accountType: Account.AccountType? = nil, completion: @escaping RequestCompletion<APIAccountBalanceReportResponse>) {
        requestQueue.async {
            let url = URL(string: ReportsEndpoint.accountBalance.path, relativeTo: self.serverURL)!
            
            let dateFormatter = Reports.dailyDateFormatter
            
            var parameters = [ReportsEndpoint.QueryParameters.period.rawValue: period.rawValue,
                              ReportsEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              ReportsEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            if let account = accountID {
                parameters[ReportsEndpoint.QueryParameters.accountID.rawValue] = String(account)
            }
            if let container = accountType {
                parameters[ReportsEndpoint.QueryParameters.container.rawValue] = container.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIAccountBalanceReportResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transaction History Reports
    
    internal func fetchTransactionHistoryReports(filtering: TransactionReportFilter, grouping: ReportGrouping?, period: Reports.Period, fromDate: Date, toDate: Date, completion: @escaping RequestCompletion<APIReportsResponse>) {
        requestQueue.async {
            let url = URL(string: ReportsEndpoint.transactionsHistory(entity: filtering.entity, id: filtering.id).path, relativeTo: self.serverURL)!
            
            let dateFormatter = Reports.dailyDateFormatter
            
            var parameters = [ReportsEndpoint.QueryParameters.period.rawValue: period.rawValue,
                              ReportsEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              ReportsEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            if let g = grouping {
                parameters[ReportsEndpoint.QueryParameters.grouping.rawValue] = g.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                
                self.network.handleResponse(type: APIReportsResponse.self, errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
}
