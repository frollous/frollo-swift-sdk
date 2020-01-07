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
import XCTest
@testable import FrolloSDK

class ReportResponseTests: XCTestCase {
    
    func testReportResponse_BudgetCategory() {
        let report = APIGroupReport.testData(maxId: 4)
        
        let budgetCategoryGroupReport = BudgetCategoryGroupReport(groupReport: report)
        
        guard let budgetCategory = BudgetCategory(id: report.id) else { XCTFail(); return }
        
        XCTAssertEqual(budgetCategoryGroupReport.budgetCategory, budgetCategory)
        XCTAssertEqual(budgetCategoryGroupReport.isIncome, report.income)
        XCTAssertEqual(budgetCategoryGroupReport.transactionIDs, report.transactionIDs)
        XCTAssertEqual(budgetCategoryGroupReport.value, report.value)
    }
    
    func testReportResponse_Category() {
        let report = APIGroupReport.testData()
        
        let category = TransactionCategoryGroupReport(groupReport: report)
        
        XCTAssertEqual(category.id, report.id)
        XCTAssertEqual(category.isIncome, report.income)
        XCTAssertEqual(category.transactionIDs, report.transactionIDs)
        XCTAssertEqual(category.value, report.value)
    }
    
    func testReportResponse_Merchant() {
        let report = APIGroupReport.testData()
        
        let merchant = MerchantGroupReport(groupReport: report)
        
        XCTAssertEqual(merchant.id, report.id)
        XCTAssertEqual(merchant.isIncome, report.income)
        XCTAssertEqual(merchant.transactionIDs, report.transactionIDs)
        XCTAssertEqual(merchant.value, report.value)
    }
    
    func testReportResponse_Tag() {
        let report = APIGroupReport.testData()
        
        let tag = TagGroupReport(groupReport: report)
        
        XCTAssertEqual(tag.isIncome, report.income)
        XCTAssertEqual(tag.transactionIDs, report.transactionIDs)
        XCTAssertEqual(tag.value, report.value)
    }
    
    func testReportResponse() {
        let report = APIReportsResponse.Report.testData(monthNumber: 1)
        let response = ReportResponse(type: BudgetCategoryGroupReport.self, report: report)
        XCTAssertEqual(response.date, report.date)
        XCTAssertEqual(response.isIncome, report.income)
        XCTAssertEqual(response.value, report.value)
    }
}
