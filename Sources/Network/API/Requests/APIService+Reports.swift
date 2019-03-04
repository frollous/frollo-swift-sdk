//
//  Network+Reports.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension APIService {
    
    // MARK: - Account Balance Reports
    
    internal func fetchAccountBalanceReports(period: ReportAccountBalance.Period, from fromDate: Date, to toDate: Date, accountID: Int64? = nil, accountType: Account.AccountType? = nil, completion: @escaping RequestCompletion<APIAccountBalanceReportResponse>) {
        requestQueue.async {
            let url = URL(string: ReportsEndpoint.accountBalance.path, relativeTo: self.serverURL)!
            
            let dateFormatter = ReportTransactionHistory.dailyDateFormatter
            
            var parameters = [ReportsEndpoint.QueryParameters.period.rawValue: period.rawValue,
                              ReportsEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              ReportsEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            if let account = accountID {
                parameters[ReportsEndpoint.QueryParameters.accountID.rawValue] = String(account)
            }
            if let container = accountType {
                parameters[ReportsEndpoint.QueryParameters.container.rawValue] = container.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIAccountBalanceReportResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transaction Current Reports
    
    internal func fetchTransactionCurrentReports(grouping: ReportGrouping, budgetCategory: BudgetCategory?, completion: @escaping RequestCompletion<APITransactionCurrentReportResponse>) {
        requestQueue.async {
            let url = URL(string: ReportsEndpoint.transactionsCurrent.path, relativeTo: self.serverURL)!
            
            var parameters = [ReportsEndpoint.QueryParameters.grouping.rawValue: grouping.rawValue]
            
            if let category = budgetCategory {
                parameters[ReportsEndpoint.QueryParameters.budgetCategory.rawValue] = category.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APITransactionCurrentReportResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Transaction History Reports
    
    internal func fetchTransactionHistoryReports(grouping: ReportGrouping, period: ReportTransactionHistory.Period, fromDate: Date, toDate: Date, budgetCategory: BudgetCategory?, completion: @escaping RequestCompletion<APITransactionHistoryReportsResponse>) {
        requestQueue.async {
            let url = URL(string: ReportsEndpoint.transactionsHistory.path, relativeTo: self.serverURL)!
            
            let dateFormatter = ReportTransactionHistory.dailyDateFormatter
            
            var parameters = [ReportsEndpoint.QueryParameters.grouping.rawValue: grouping.rawValue,
                              ReportsEndpoint.QueryParameters.period.rawValue: period.rawValue,
                              ReportsEndpoint.QueryParameters.fromDate.rawValue: dateFormatter.string(from: fromDate),
                              ReportsEndpoint.QueryParameters.toDate.rawValue: dateFormatter.string(from: toDate)]
            
            if let category = budgetCategory {
                parameters[ReportsEndpoint.QueryParameters.budgetCategory.rawValue] = category.rawValue
            }
            
            self.network.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APITransactionHistoryReportsResponse.self, response: response, completion: completion)
            }
        }
    }
    
}
