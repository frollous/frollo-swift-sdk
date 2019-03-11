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
