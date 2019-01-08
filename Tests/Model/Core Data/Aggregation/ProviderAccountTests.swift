//
//  ProviderAccountTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class ProviderAccountTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingProviderAccount() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let providerAccountResponse = APIProviderAccountResponse.testCompleteDate()
            
            let providerAccount = ProviderAccount(context: managedObjectContext)
            providerAccount.update(response: providerAccountResponse, context: managedObjectContext)
            
            XCTAssertEqual(providerAccount.providerAccountID, providerAccountResponse.id)
            XCTAssertEqual(providerAccount.providerID, providerAccountResponse.providerID)
            XCTAssertEqual(providerAccount.editable, providerAccountResponse.editable)
            XCTAssertEqual(providerAccount.nextRefresh, providerAccountResponse.refreshStatus.nextRefresh)
            XCTAssertEqual(providerAccount.lastRefreshed, providerAccountResponse.refreshStatus.lastRefreshed)
            XCTAssertEqual(providerAccount.refreshStatus, providerAccountResponse.refreshStatus.status)
            XCTAssertEqual(providerAccount.refreshSubStatus, providerAccountResponse.refreshStatus.subStatus)
            XCTAssertEqual(providerAccount.refreshAdditionalStatus, providerAccountResponse.refreshStatus.additionalStatus)
            XCTAssertEqual(providerAccount.loginForm?.id, providerAccountResponse.loginForm?.id)
            XCTAssertNotNil(providerAccount.loginForm)
        }
    }
    
}
