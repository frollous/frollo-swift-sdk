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

class BillPaymentTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingBillPayment() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let billPaymentResponse = APIBillPaymentResponse.testCompleteData()
            
            let billPayment = BillPayment(context: managedObjectContext)
            billPayment.update(response: billPaymentResponse, context: managedObjectContext)
            
            XCTAssertEqual(billPaymentResponse.id, billPayment.billPaymentID)
            XCTAssertEqual(billPaymentResponse.billID, billPayment.billID)
            XCTAssertEqual(billPaymentResponse.name, billPayment.name)
            XCTAssertEqual(billPaymentResponse.merchantID, billPayment.merchantID)
            XCTAssertEqual(billPaymentResponse.date, billPayment.dateString)
            XCTAssertEqual(billPaymentResponse.paymentStatus, billPayment.paymentStatus)
            XCTAssertEqual(billPaymentResponse.frequency, billPayment.frequency)
            XCTAssertEqual(billPaymentResponse.amount, billPayment.amount?.stringValue)
        }
    }
    
    func testUpdateBillPaymentRequest() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let billPayment = BillPayment(context: managedObjectContext)
            billPayment.populateTestData()
            
            let updateRequest = billPayment.updateRequest()
            
            XCTAssertEqual(billPayment.paymentStatus, updateRequest.status)
        }
    }

}
