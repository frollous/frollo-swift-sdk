//
//  APITransactionHistoryReportResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APITransactionHistoryReportsResponse {
    
    static func testGroupReports() -> [APITransactionHistoryReportsResponse.Report.GroupReport] {
        var reports = [APITransactionHistoryReportsResponse.Report.GroupReport]()
        
        for _ in 1...6 {
            let report = APITransactionHistoryReportsResponse.Report.GroupReport(budget: "20.56",
                                                                                id: Int64.random(in: 1...10000000),
                                                                                name: String.randomString(range: 1...20),
                                                                                value: "8.97")
            
            reports.append(report)
        }
        
        return reports
    }
    
    static func testReports() -> [APITransactionHistoryReportsResponse.Report] {
        var reports = [APITransactionHistoryReportsResponse.Report]()
        
        for i in 1...12 {
            let report = APITransactionHistoryReportsResponse.Report(groups: APITransactionHistoryReportsResponse.testGroupReports(),
                                                                     budget: "11.00",
                                                                     date: "2018-" + String(i) + "-01",
                                                                     value: "10.32")
            
            reports.append(report)
        }
        
        return reports
    }
    
    static func testCompleteData() -> APITransactionHistoryReportsResponse {
        return APITransactionHistoryReportsResponse(data: APITransactionHistoryReportsResponse.testReports())
    }
    
}
