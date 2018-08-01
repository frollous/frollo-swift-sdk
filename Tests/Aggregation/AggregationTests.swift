//
//  AggregationTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class AggregationTests: XCTestCase {
    
    let keychainService = "AggregationTests"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testRefreshProvidersIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let aggregation = Aggregation(database: database, network: network)
            
            aggregation.refreshProviders { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                
                do {
                    let fetchedProviders = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedProviders.count, 311)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshProvidersUpdate() {
        // TODO: Implement
    }
    
}
