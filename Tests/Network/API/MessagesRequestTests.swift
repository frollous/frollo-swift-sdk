//
//  MessagesRequestTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class MessagesRequestTests: XCTestCase {
    
    private let keychainService = "MessagesRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testFetchMessages() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchMessages { (response, error) in
            XCTAssertNil(error)
            
            if let messagesResponse = response {
                XCTAssertEqual(messagesResponse.count, 100)
                
                if let firstMessage = messagesResponse.first {
                    XCTAssertEqual(firstMessage.id, 52473)
                    XCTAssertEqual(firstMessage.event, "DEMO_START")
                    XCTAssertEqual(firstMessage.userEventID, 50581)
                    XCTAssertEqual(firstMessage.placement, 1020)
                    XCTAssertFalse(firstMessage.persists)
                    XCTAssertFalse(firstMessage.read)
                    XCTAssertFalse(firstMessage.clicked)
                    XCTAssertEqual(firstMessage.messageTypes, [.homeNudge])
                    XCTAssertEqual(firstMessage.designType, .information)
                    XCTAssertEqual(firstMessage.title, "Well done Jacob!")
                    XCTAssertEqual(firstMessage.contentType, .text)
                    XCTAssertEqual(firstMessage.content!, APIMessageResponse.Content.text(APIMessageResponse.Content.Text(body: "Some body")))
                    XCTAssertEqual(firstMessage.action?.title, "Claim Points")
                    XCTAssertEqual(firstMessage.action?.link, "frollo://dashboard/")
                    XCTAssertEqual(firstMessage.action?.openExternal, false)
                    XCTAssertNil(firstMessage.button)
                    XCTAssertNil(firstMessage.header)
                    XCTAssertNil(firstMessage.footer)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }

        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMessagesSkipsInvalid() {
        
    }
    
    func testFetchUnreadMessages() {
        
    }

}
