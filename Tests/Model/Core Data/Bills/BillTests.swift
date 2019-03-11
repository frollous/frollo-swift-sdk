//
// Copyright © 2018 Frollo. All rights reserved.
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

class BillTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingBill() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let billResponse = APIBillResponse.testCompleteData()
            
            let bill = Bill(context: managedObjectContext)
            bill.update(response: billResponse, context: managedObjectContext)
            
            XCTAssertEqual(billResponse.id, bill.billID)
            XCTAssertEqual(billResponse.accountID, bill.accountID)
            XCTAssertEqual(billResponse.averageAmount, bill.averageAmount.stringValue)
            XCTAssertEqual(billResponse.billType, bill.billType)
            XCTAssertEqual(billResponse.description, bill.details)
            XCTAssertEqual(billResponse.dueAmount, bill.dueAmount.stringValue)
            XCTAssertEqual(billResponse.endDate, bill.endDateString)
            XCTAssertEqual(billResponse.frequency, bill.frequency)
            XCTAssertEqual(billResponse.lastAmount, bill.lastAmount?.stringValue)
            XCTAssertEqual(billResponse.lastPaymentDate, bill.lastPaymentDateString)
            XCTAssertEqual(billResponse.merchant?.id, bill.merchantID)
            XCTAssertEqual(billResponse.name, bill.name)
            XCTAssertEqual(billResponse.nextPaymentDate, bill.nextPaymentDateString)
            XCTAssertEqual(billResponse.note, bill.notes)
            XCTAssertEqual(billResponse.paymentStatus, bill.paymentStatus)
            XCTAssertEqual(billResponse.status, bill.status)
            XCTAssertEqual(billResponse.category?.id, bill.transactionCategoryID)
        }
    }
    
    func testUpdateBillRequest() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let bill = Bill(context: managedObjectContext)
            bill.populateTestData()
            
            let updateRequest = bill.updateRequest()
            
            XCTAssertEqual(bill.billType, updateRequest.billType)
            XCTAssertEqual(bill.dueAmount.stringValue, updateRequest.dueAmount)
            XCTAssertEqual(bill.endDateString, updateRequest.endDate)
            XCTAssertEqual(bill.frequency, updateRequest.frequency)
            XCTAssertEqual(bill.name, updateRequest.name)
            XCTAssertEqual(bill.nextPaymentDateString, updateRequest.nextPaymentDate)
            XCTAssertEqual(bill.notes, updateRequest.note)
        }
    }

}
