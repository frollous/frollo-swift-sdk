//
//  AccountBalanceTierTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class AccountBalanceTierTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingBalanceTier() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let accountBalanceTierResponse = APIAccountResponse.BalanceTier(description: UUID().uuidString,
                                                                        min: String(arc4random()),
                                                                        max: String(arc4random()))
        
        let accountBalanceTier = AccountBalanceTier(context: managedObjectContext)
        accountBalanceTier.update(response: accountBalanceTierResponse)
        
        XCTAssertEqual(accountBalanceTier.name, accountBalanceTierResponse.description)
        XCTAssertEqual(accountBalanceTier.maximum, NSDecimalNumber(string: accountBalanceTierResponse.max))
        XCTAssertEqual(accountBalanceTier.minimum, NSDecimalNumber(string: accountBalanceTierResponse.min))
    }
    
}
