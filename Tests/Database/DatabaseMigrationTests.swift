//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Progress.totalUnitCount), let progress = object as? Progress {
            XCTAssertEqual(progress.totalUnitCount, 11)
            
            progress.removeObserver(self, forKeyPath: #keyPath(Progress.totalUnitCount))
        }
    }
    
    // MARK: - Helpers
    
    private func populateTestDataNamed(name: String, path: URL? = nil) -> URL {
        let tempFolder = path ?? tempFolderPath()
        
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
        
        if let lastPath = subPaths.last {
            let model = NSManagedObjectModel(contentsOf: lastPath)!
            generateCoreDataTestDatabase(for: model, named: lastPath.deletingPathExtension().lastPathComponent)
        }
    }
    
    private func generateCoreDataTestDatabase(for model: NSManagedObjectModel, named: String) {
        let persistentContainer = NSPersistentContainer(name: named, managedObjectModel: model)
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            let context = persistentContainer.newBackgroundContext()
            
            context.performAndWait {
                for entity in persistentContainer.managedObjectModel.entities {
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
                
                try! context.save()
            }
        }
    }
    
    private func generateFakeCoreDataModelTestDatabase() {
        let modelPath = Bundle(for: type(of: self)).url(forResource: "TestInvalidDataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelPath)!
        generateCoreDataTestDatabase(for: model, named: fakeTestDataModelName)
    }
    
    // MARK: - Test Data
    
//    // Uncomment to generate test data for each data model. Do this whenever adding a new Core Data model version
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
        
        sleep(1)
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNotNil(error)
            
            database.setup(completionHandler: { (error) in
                XCTAssertNil(error)
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testDatabaseResetsIfMigrationFails() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        try? FileManager.default.removeItem(at: Frollo.defaultDataFolderURL)
        
        try? FileManager.default.createDirectory(at: Frollo.defaultDataFolderURL, withIntermediateDirectories: true, attributes: nil)
        _ = populateTestDataNamed(name: fakeTestDataModelName, path: Frollo.defaultDataFolderURL)
        
        sleep(1)
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    XCTAssertFalse(FileManager.default.fileExists(atPath: sdk._database.storeURL.path))
                    XCTAssertFalse(sdk.oAuth2Authentication?.loggedIn == true)
                        
                    expectation1.fulfill()
                case .success:
                    XCTFail("Invalid model should fail")
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testMigrationFrom100() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.0.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom110() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.1.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom120() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.2.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom130() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.3.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom131() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.3.1")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom132() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.3.2")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom133() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.3.3")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom140() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.4.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom150() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.5.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationFrom151() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.5.1")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testMigrationProgress() {
        let expectation1 = XCTestExpectation(description: "Migration Completion")
        
        let path = populateTestDataNamed(name: "FrolloSDKDataModel-1.0.0")
        
        let database = Database(path: path)
        
        XCTAssertTrue(database.needsMigration())
        
        let progress = database.migrate { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        XCTAssertNotNil(progress)
        
        progress?.addObserver(self, forKeyPath: "totalUnitCount", options: .new, context: nil)
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
}
