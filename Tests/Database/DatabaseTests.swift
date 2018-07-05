//
//  DatabaseTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 3/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest

@testable import FrolloSDK

class DatabaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        removeDatabase()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        removeDatabase()
    }
    
    // MARK: - Helpers
    
    func removeDatabase() {
        let databaseURL = Database.storeURL
        let databaseSHMURL = Database.storeURL.appendingPathExtension("-shm")
        let databaseWALURL = Database.storeURL.appendingPathExtension("-wal")
        
        try? FileManager.default.removeItem(at: databaseURL)
        try? FileManager.default.removeItem(at: databaseSHMURL)
        try? FileManager.default.removeItem(at: databaseWALURL)
    }
    
    func insertTestData(database: Database) {
        let context = database.newBackgroundContext()
        
        for entity in database.persistentContainer.managedObjectModel.entities {
            guard let entityName = entity.name
                else {
                    continue
            }
            
            for _ in 0..<100 {
                _ = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            }
        }
        
        XCTAssertNoThrow(try context.save())
    }
    
    func checkDatabaseEmpty(database: Database) {
        let context = database.viewContext
        
        for entity in database.persistentContainer.managedObjectModel.entities {
            guard let entityName = entity.name
                else {
                    continue
            }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            fetchRequest.resultType = .dictionaryResultType
            
            let results = try! context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 0)
        }
    }
    
    // MARK: - Tests
    
    func testDatabaseSetupFailure() {
        let expectation1 = expectation(description: "Setup Callback")
        
        let database = Database()
        
        // Insert garbage SQLite store
        FileManager.default.createFile(atPath: Database.storeURL.path, contents: Data.randomData(length: 1000), attributes: nil)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        removeDatabase()
    }
    
    func testDatabaseSetupSuccess() {
        let expectation1 = expectation(description: "Setup Callback")
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: Database.storeURL.path))
        
        let database = Database()
        
        XCTAssertFalse(database.needsMigration())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: Database.storeURL.path))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDatabaseReset() {
        let expectation1 = expectation(description: "Reset Callback")
        
        let database = Database()
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.insertTestData(database: database)
            
            database.reset(completionHandler: { (error) in
                XCTAssertNil(error)
                
                self.checkDatabaseEmpty(database: database)
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 10.0)
    }
    
}
