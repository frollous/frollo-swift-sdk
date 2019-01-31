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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func insertTestData(database: Database) {
        let context = database.newBackgroundContext()
        
        context.performAndWait {
            for entity in database.persistentContainer.managedObjectModel.entities {
                guard let entityName = entity.name
                    else {
                        continue
                }
                
                for _ in 0..<100 {
                    let model = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
                    if let testableModel = model as? TestableCoreData {
                        testableModel.populateTestData()
                    }
                }
            }
            
            do {
                try context.save()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
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
    
    // MARK: - Setup Tests
    
    func testDatabaseSetupFailure() {
        let expectation1 = expectation(description: "Setup Callback")
        
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        // Insert garbage SQLite store
        FileManager.default.createFile(atPath: database.storeURL.path, contents: Data.randomData(length: 1000), attributes: nil)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: path)
    }
    
    func testDatabaseSetupSuccess() {
        let expectation1 = expectation(description: "Setup Callback")
        
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        XCTAssertFalse(database.needsMigration())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: database.storeURL.path))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: path)
    }
    
    // MARK: - Reset tests
    
    func testDatabaseReset() {
        let expectation1 = expectation(description: "Reset Callback")
        
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.insertTestData(database: database)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                database.reset() { (error) in
                    XCTAssertNil(error)
                    
                    self.checkDatabaseEmpty(database: database)
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 30.0)
        
        try? FileManager.default.removeItem(at: path)
    }
    
}
