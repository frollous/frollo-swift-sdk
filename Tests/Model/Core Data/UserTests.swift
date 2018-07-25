//
//  UserTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 24/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func tempFolderPath() -> URL {
        var tempFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        tempFolder.appendPathComponent(UUID().uuidString, isDirectory: true)
        
        try? FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true, attributes: nil)
        
        return tempFolder
    }
    
    // MARK: - Tests
    
    func testUserModelUpdate() {
        let expectation1 = expectation(description: "Database setup")
        
        let path = tempFolderPath()
        
        let database = Database(path: path)
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
            let userModel = User(context: moc)
            userModel.populateTestData()
            
            let userResponseModel = APIUserResponse.testData()
            
            userModel.update(response: userResponseModel)
            
            XCTAssertEqual(userModel.userID, userResponseModel.userID)
            XCTAssertEqual(userModel.firstName, userResponseModel.firstName)
            XCTAssertEqual(userModel.lastName, userResponseModel.lastName)
            XCTAssertEqual(userModel.email, userResponseModel.email)
            XCTAssertEqual(userModel.emailVerified, userResponseModel.emailVerified)
            XCTAssertEqual(userModel.status, userResponseModel.status)
            XCTAssertEqual(userModel.primaryCurrency, userResponseModel.primaryCurrency)
            XCTAssertEqual(userModel.gender, userResponseModel.gender)
            XCTAssertEqual(userModel.dateOfBirth, userResponseModel.dateOfBirth)
            XCTAssertEqual(userModel.postcode, userResponseModel.address?.postcode)
            XCTAssertEqual(userModel.householdType, userResponseModel.householdType)
            XCTAssertEqual(userModel.occupation, userResponseModel.occupation)
            XCTAssertEqual(userModel.industry, userResponseModel.industry)
            XCTAssertEqual(userModel.householdSize, userResponseModel.householdSize)
            XCTAssertEqual(userModel.facebookID, userResponseModel.facebookID)
            XCTAssertEqual(userModel.validPassword, userResponseModel.validPassword)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
}
