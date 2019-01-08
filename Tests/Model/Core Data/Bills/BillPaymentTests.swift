//
//  BillPaymentTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
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
            
            XCTAssertEqual(billPayment.dateString, updateRequest.date)
            XCTAssertEqual(billPayment.paymentStatus, updateRequest.status)
        }
    }

}
