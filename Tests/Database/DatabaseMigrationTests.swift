//
//  DatabaseMigrationTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 3/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
import CoreData
@testable import FrolloSDK

class DatabaseMigrationTests: XCTestCase {
    
    let fakeTestDataModelName = "FakeDatabaseModel"
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: NSPersistentContainer.defaultDirectoryURL())
        try! FileManager.default.createDirectory(at: NSPersistentContainer.defaultDirectoryURL(), withIntermediateDirectories: true, attributes: nil)
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
    
    private func populateTestDataNamed(name: String) -> URL {
        let tempFolder = tempFolderPath()
        
        let databaseFileURL = Bundle(for: type(of: self)).url(forResource: name, withExtension: "sqlite")!
        let databaseSHMFileURL = databaseFileURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        let databaseWALFileURL = databaseFileURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let databaseFiles = [databaseFileURL, databaseSHMFileURL, databaseWALFileURL]
        for file in databaseFiles {
            let destinationURL = tempFolder.appendingPathComponent(Database.DatabaseConstants.storeName).appendingPathExtension(file.pathExtension)
            try! FileManager.default.copyItem(at: file, to: destinationURL)
        }
        
        return tempFolder
    }
    
    private func latestModelName() -> String {
        let modelPath = Bundle(for: Database.self).url(forResource: Database.DatabaseConstants.modelName, withExtension: Database.DatabaseConstants.parentModelExtension)!
        var subPaths = Bundle(for: Database.self).urls(forResourcesWithExtension: Database.DatabaseConstants.modelExtension, subdirectory: modelPath.lastPathComponent)!
        
        subPaths.sort { (urlA: URL, urlB: URL) -> Bool in
            let urlAVersion = urlA.deletingPathExtension().lastPathComponent.components(separatedBy: "-").last!
            let urlBVersion = urlB.deletingPathExtension().lastPathComponent.components(separatedBy: "-").last!
            
            return urlAVersion.compare(urlBVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending
        }
        
        return subPaths.last!.deletingPathExtension().lastPathComponent
    }
    
    // MARK: - Generate Test Data
    
    private func generateCoreDataModelTestDatabases() {
        // Gather all models
        let modelPath = Bundle(for: Database.self).url(forResource: Database.DatabaseConstants.modelName, withExtension: Database.DatabaseConstants.parentModelExtension)!
        var subPaths = Bundle(for: Database.self).urls(forResourcesWithExtension: Database.DatabaseConstants.modelExtension, subdirectory: modelPath.lastPathComponent)!
        
        subPaths.sort { (urlA: URL, urlB: URL) -> Bool in
            let urlAVersion = urlA.deletingPathExtension().lastPathComponent.components(separatedBy: "-").last!
            let urlBVersion = urlB.deletingPathExtension().lastPathComponent.components(separatedBy: "-").last!
            
            return urlAVersion.compare(urlBVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending
        }
        
        for path in subPaths {
            let model = NSManagedObjectModel(contentsOf: path)!
            generateCoreDataTestDatabase(for: model, named: path.deletingPathExtension().lastPathComponent)
        }
    }
    
    private func generateCoreDataTestDatabase(for model: NSManagedObjectModel, named: String) {
        let persistentContainer = NSPersistentContainer(name: named, managedObjectModel: model)
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            let context = persistentContainer.newBackgroundContext()
            
            for entity in persistentContainer.managedObjectModel.entities {
                guard let entityName = entity.name
                    else {
                        continue
                }
                
                for _ in 0..<100 {
                    _ = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
                }
            }
            
            try! context.save()
        }
    }
    
    private func generateFakeCoreDataModelTestDatabase() {
        let modelPath = Bundle(for: type(of: self)).url(forResource: "TestInvalidDataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelPath)!
        generateCoreDataTestDatabase(for: model, named: fakeTestDataModelName)
    }
    
    // MARK: - Test Data
    
    // Uncomment to generate test data for each data model. Do this whenever adding a new Core Data model version
//    func testGenerateTestCoreDataDatabases() {
//        generateCoreDataModelTestDatabases()
//        generateFakeCoreDataModelTestDatabase()
//    }
    
    // MARK: - Migration Tests
    
    func testMigrationIsNotNeededIfNoPersistentStore() {
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        XCTAssertFalse(database.needsMigration())
    }
    
    func testMigrationIsNotNeededIfPersistentStoreMatchedCurrentModel() {
        let path = populateTestDataNamed(name: latestModelName())
        
        let database = Database(path: path)
        
        XCTAssertFalse(database.needsMigration())
    }
    
    func testMigrationIsNeededIfPersistentStoreExistsAndDoesNotMatchCurrentModel() {
        let path = populateTestDataNamed(name: fakeTestDataModelName)
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
    }
    
    func testMigrationFailureFromInvalidModel() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: fakeTestDataModelName)
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (success) in
            XCTAssertFalse(success)
            
            database.setup(completionHandler: { (error) in
                XCTAssertNil(error)
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testMigrationFrom100To110() {
        // Implement when we change the DB
    }
    
}
