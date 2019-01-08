//
//  MerchantTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class MerchantTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingMerchant() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let merchantResponse = APIMerchantResponse.testCompleteData()
            
            let merchant = Merchant(context: managedObjectContext)
            merchant.update(response: merchantResponse, context: managedObjectContext)
            
            XCTAssertEqual(merchant.merchantID, merchantResponse.id)
            XCTAssertEqual(merchant.name, merchantResponse.name)
            XCTAssertEqual(merchant.merchantType, merchantResponse.merchantType)
            XCTAssertEqual(merchant.smallLogoURL, URL(string: merchantResponse.smallLogoURL))
        }
    }
    
}
