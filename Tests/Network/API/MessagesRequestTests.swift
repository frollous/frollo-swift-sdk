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
        Keychain(service: keychainService).removeAll()
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
                XCTAssertEqual(messagesResponse.count, 74)
                
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
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchMessages { (response, error) in
            XCTAssertNil(error)
            
            if let messagesResponse = response {
                XCTAssertEqual(messagesResponse.count, 72)
                
                let message = messagesResponse[1]
                XCTAssertEqual(message.id, 52432)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchUnreadMessages() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchUnreadMessages { (response, error) in
            XCTAssertNil(error)
            
            if let messagesResponse = response {
                XCTAssertEqual(messagesResponse.count, 7)
                
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
                    XCTAssertEqual(firstMessage.contentType, .html5)
                    XCTAssertEqual(firstMessage.content!, APIMessageResponse.Content.html(APIMessageResponse.Content.HTML(body: "<html></html>")))
                    XCTAssertEqual(firstMessage.action?.title, "Claim Points")
                    XCTAssertEqual(firstMessage.action?.link, "frollo://dashboard/")
                    XCTAssertEqual(firstMessage.action?.openExternal, false)
                    XCTAssertNil(firstMessage.button)
                    XCTAssertNil(firstMessage.header)
                    XCTAssertNil(firstMessage.footer)
                }
                
                for message in messagesResponse {
                    XCTAssertFalse(message.read)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMessageByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        let id: Int64 = 12345
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchMessage(messageID: id) { (response, error) in
            XCTAssertNil(error)
            
            if let message = response {
                XCTAssertEqual(message.id, id)
                XCTAssertEqual(message.event, "TEST_WEBVIEW_AUTH")
                XCTAssertEqual(message.userEventID, 47936)
                XCTAssertEqual(message.placement, 1)
                XCTAssertTrue(message.persists)
                XCTAssertFalse(message.read)
                XCTAssertFalse(message.clicked)
                XCTAssertEqual(message.messageTypes, [.homeNudge])
                XCTAssertEqual(message.designType, .information)
                XCTAssertEqual(message.title, "Test WebView Auth")
                XCTAssertEqual(message.contentType, .text)
                XCTAssertEqual(message.content!, APIMessageResponse.Content.text(APIMessageResponse.Content.Text(body: "Test WebView Auth")))
                XCTAssertNil(message.action?.title)
                XCTAssertEqual(message.action?.link, "https://example.com")
                XCTAssertEqual(message.action?.openExternal, false)
                XCTAssertEqual(message.button?.title, "Test Page")
                XCTAssertEqual(message.button?.link, "https://example.com")
                XCTAssertEqual(message.button?.openExternal, false)
                XCTAssertNil(message.header)
                XCTAssertNil(message.footer)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateMessage() {
        let expectation1 = expectation(description: "Network Request")

        let url = URL(string: "https://api.example.com")!

        let id: Int64 = 12345
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = Keychain.validNetworkKeychain(service: keychainService)

        let network = Network(serverURL: url, keychain: keychain)

        let request = APIMessageUpdateRequest(clicked: false, read: true)
        network.updateMessage(messageID: id, request: request) { (response, error) in
            XCTAssertNil(error)

            if let messageResponse = response {
                XCTAssertEqual(messageResponse.id, id)
            } else {
                XCTFail("No response object")
            }

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)
    }

}
