//
//  EventsTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class EventsTests: XCTestCase {
    
    let keychainService = "EventsTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTriggerEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + EventsEndpoint.events.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let events = Events(network: network)
        
        events.triggerEvent("TEST_EVENT", after: 5) { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandleEventHandled() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let events = Events(network: network)
        
        let eventName = "TEST_EVENT"
        
        events.handleEvent(eventName) { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandleEventNotHandled() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let events = Events(network: network)
        
        let eventName = "UNKNOWN_EVENT"
        
        events.handleEvent(eventName) { (handled, error) in
            XCTAssertFalse(handled)
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandleTransactionsUpdatedEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.refreshTransactionsNotification, object: nil) { (notification) -> Bool in
            XCTAssertNotNil(notification.userInfo)
            
            guard let transactionIDs = notification.userInfo?[Aggregation.refreshTransactionIDsKey] as? [Int64]
                else {
                    XCTFail()
                    return true
            }
            
            XCTAssertEqual(transactionIDs, [45123, 986, 7000072])
            
            return true
        }
        
        let url = URL(string: "https://api.example.com")!
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let events = Events(network: network)
        
        let notificationUpdated = NotificationPayload.testTransactionUpdatedData()
        
        events.handleEvent("T_UPDATED", notification: notificationUpdated) { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }

}
