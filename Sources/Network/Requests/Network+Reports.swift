//
//  Network+Reports.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    // MARK: - Transaction Current Reports
    
    internal func fetchTransactionCurrentReports(grouping: ReportGrouping, budgetCategory: BudgetCategory?, completion: @escaping RequestCompletion<APITransactionCurrentReportResponse>) {
        requestQueue.async {
            let url = URL(string: ReportsEndpoint.transactionsCurrent.path, relativeTo: self.serverURL)!
            
            var parameters = [ReportsEndpoint.QueryParameters.grouping.rawValue: grouping.rawValue]
            
            if let category = budgetCategory {
                parameters[ReportsEndpoint.QueryParameters.budgetCategory.rawValue] = category.rawValue
            }
            
            self.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APITransactionCurrentReportResponse.self, response: response, completion: completion)
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
            
            self.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APITransactionHistoryReportsResponse.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Response Handling
    
    

}
