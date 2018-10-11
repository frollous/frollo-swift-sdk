//
//  PreferencesPersistenceTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 23/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class PreferencesPersistenceTests: XCTestCase {
    
    private let tempFolderPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(UUID().uuidString, isDirectory: true)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Create temp folder
        try? FileManager.default.createDirectory(at: tempFolderPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        try? FileManager.default.removeItem(at: tempFolderPath)
    }
    
    // MARK: - Helpers
    
    private func tempPath() -> URL {
        return tempFolderPath.appendingPathComponent(UUID().uuidString)
    }
    
    // MARK: - Tests
    
    func testPreferencesStoring() {
        let path = tempPath()
        
        let testKey1 = "TestData"
        let testData = Data.randomData(length: 32)
        let testKey2 = "TestString"
        let testString = UUID().uuidString
        
        let persistence = PreferencesPersistence(path: path)
        persistence[testKey1] = testData
        persistence[testKey2] = testString
        
        XCTAssertEqual(persistence[testKey1] as? Data, testData)
        XCTAssertEqual(persistence[testKey2] as? String, testString)
    }
    
    func testPreferencesPersisted() {
        let path = tempPath()
        
        let testKey1 = "TestData"
        let testData = Data.randomData(length: 32)
        let testKey2 = "TestString"
        let testString = UUID().uuidString
        
        var persistence = PreferencesPersistence(path: path)
        persistence[testKey1] = testData
        persistence[testKey2] = testString
        
        persistence.synchronise()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: path.path))
        
        // Reload from disk
        persistence = PreferencesPersistence(path: path)
        
        XCTAssertEqual(persistence[testKey1] as? Data, testData)
        XCTAssertEqual(persistence[testKey2] as? String, testString)
    }
    
    func testPreferencesAutomaticallyPersisted() {
        let expectation1 = expectation(description: "Wait for persistence")
        
        let path = tempPath()
        
        let testKey1 = "TestData"
        let testData = Data.randomData(length: 32)
        let testKey2 = "TestString"
        let testString = UUID().uuidString
        
        var persistence = PreferencesPersistence(path: path)
        persistence[testKey1] = testData
        persistence[testKey2] = testString
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            XCTAssertTrue(FileManager.default.fileExists(atPath: path.path))
            
            // Reload from disk
            persistence = PreferencesPersistence(path: path)
            
            XCTAssertEqual(persistence[testKey1] as? Data, testData)
            XCTAssertEqual(persistence[testKey2] as? String, testString)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testResetPreferencesPersistence() {
        let path = tempPath()
        
        let persistence = PreferencesPersistence(path: path)
        persistence["TestData"] = Data.randomData(length: 32)
        persistence["TestString"] = UUID().uuidString
        
        persistence.synchronise()
        
        sleep(1)
        
        persistence.reset()
        
        XCTAssertNil(persistence["TestData"])
        XCTAssertNil(persistence["TestString"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: path.path))
    }
    
}
