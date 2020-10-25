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

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class ImagesTests: XCTestCase {
    
    let keychainService = "ImagesTests"
    
    private var expectations = [XCTestExpectation]()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        expectations = []
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testFetchImages() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testImage1 = Image(context: managedObjectContext)
                testImage1.populateTestData()
                testImage1.imageTypes = ["goal"]
                
                let testImage2 = Image(context: managedObjectContext)
                testImage2.populateTestData()
                testImage2.imageTypes = ["budget"]
                
                let testImage3 = Image(context: managedObjectContext)
                testImage3.populateTestData()
                testImage3.imageTypes = ["derp", "test"]
                
                try! managedObjectContext.save()
            }
            
            let images = Images(database: database, service: service)
            
            let fetchedImages = images.images(context: database.viewContext, imageTypes: ["goal", "budget"])
            
            XCTAssertNotNil(fetchedImages)
            XCTAssertEqual(fetchedImages?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testImagesFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testImage1 = Image(context: managedObjectContext)
                testImage1.populateTestData()
                
                let testImage2 = Image(context: managedObjectContext)
                testImage2.populateTestData()
                testImage2.imageTypes = ["derp", "test"]
                
                let testImage3 = Image(context: managedObjectContext)
                testImage3.populateTestData()
                
                try! managedObjectContext.save()
            }
            
            let images = Images(database: database, service: service)
            
            let fetchedResultsController = images.imagesFetchedResultsController(context: database.viewContext, imageTypes: ["hello"])
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshImages() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ImagesEndpoint.images.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "images_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testImage1 = Image(context: managedObjectContext)
                testImage1.populateTestData()
                
                let testImage2 = Image(context: managedObjectContext)
                testImage2.populateTestData()
                testImage2.imageTypes = ["derp", "test"]
                
                let testImage3 = Image(context: managedObjectContext)
                testImage3.populateTestData()
                
                try! managedObjectContext.save()
            }
            
            let images = Images(database: database, service: service)
            
            images.refreshImages(completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
                        
                        do {
                            let fetchedImages = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedImages.count, 3)
                            
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            })
            
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshImagesFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ImagesEndpoint.images.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "images_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { error in
            XCTAssertNil(error)
            
            let images = Images(database: database, service: service)
            
            images.refreshImages { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }

}
