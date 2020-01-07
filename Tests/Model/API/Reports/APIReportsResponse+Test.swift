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

extension APIGroupReport {
    static func testData(maxId: Int64 = 10000000) -> APIGroupReport {
        let range = 1...maxId
        return APIGroupReport(
            income: Bool.random(),
            id: Int64.random(in: range),
            name: String.randomString(range: 1...20),
            transactionIDs: [Int64.random(in: 1...Int64.max), Int64.random(in: 1...Int64.max), Int64.random(in: 1...Int64.max)],
            value: 8.97
        )
    }
}

extension APIReportsResponse.Report {
    static func testData(monthNumber: Int) -> APIReportsResponse.Report {
        return APIReportsResponse.Report(groups: APIReportsResponse.testGroupReports(),
                                         income: true,
                                         date: "2018-" + String(monthNumber) + "-01",
                                         value: 10.32)
    }
}

extension APIReportsResponse {
    
    static func testGroupReports() -> [APIGroupReport] {
        var reports = [APIGroupReport]()
        
        for _ in 1...6 {
            let report = APIGroupReport.testData()
            
            reports.append(report)
        }
        
        return reports
    }
    
    static func testReports() -> [APIReportsResponse.Report] {
        var reports = [APIReportsResponse.Report]()
        
        for i in 1...12 {
            let report = APIReportsResponse.Report.testData(monthNumber: i)
            reports.append(report)
        }
        
        return reports
    }
    
    static func testCompleteData() -> APIReportsResponse {
        return APIReportsResponse(data: APIReportsResponse.testReports())
    }
    
}
