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

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class ReportsRequestTests: XCTestCase {
    
    private let keychainService = "ReportsRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testFetchAccountBalanceReports() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ReportsEndpoint.accountBalance.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_balance_reports_by_day_2018-10-29_2019-01-29", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let fromDate = ReportAccountBalance.dailyDateFormatter.date(from: "2018-10-29")!
        let toDate = ReportAccountBalance.dailyDateFormatter.date(from: "2019-01-29")!
        
        service.fetchAccountBalanceReports(period: .day, from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.count, 94)
                    
                    if let firstReport = response.data.first {
                        XCTAssertEqual(firstReport.value, "90602.10")
                        XCTAssertEqual(firstReport.date, "2018-10-28")
                        
                        XCTAssertEqual(firstReport.accounts.count, 7)
                        
                        if let firstBalanceReport = firstReport.accounts.first {
                            XCTAssertEqual(firstBalanceReport.id, 542)
                            XCTAssertEqual(firstBalanceReport.currency, "AUD")
                            XCTAssertEqual(firstBalanceReport.value, "-1191.45")
                        } else {
                            XCTFail("No category report")
                        }
                    } else {
                        XCTFail("No report")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }

}
