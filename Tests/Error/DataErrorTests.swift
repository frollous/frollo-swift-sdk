//
//  DataErrorTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 9/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class DataErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDatabaseErrorCorrupt() {
        let error = DataError(type: .database, subType: .corrupt)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .corrupt)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.Corrupted"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorDiskFull() {
        let error = DataError(type: .database, subType: .diskFull)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .diskFull)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.DiskFullError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorMigrationFailed() {
        let error = DataError(type: .database, subType: .migrationFailed)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .migrationFailed)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.MigrationFailed"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorUnknown() {
        let error = DataError(type: .database, subType: .unknown)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .unknown)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.UnknownError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testGenericErrorUnknown() {
        let error = DataError(type: .unknown, subType: .unknown)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertEqual(error.subType, .unknown)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Generic.UnknownError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.unknown.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testErrorMismatchIsUnknown() {
        let error = DataError(type: .unknown, subType: .corrupt)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertEqual(error.subType, .corrupt)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Generic.UnknownError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.unknown.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
}
