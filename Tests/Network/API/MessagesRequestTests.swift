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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint, preemptiveRefreshTime: 180)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchMessages { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 39)
                    
                    if let firstMessage = response.first {
                        XCTAssertEqual(firstMessage.id, 52473)
                        XCTAssertEqual(firstMessage.event, "DEMO_START")
                        XCTAssertEqual(firstMessage.userEventID, 50581)
                        XCTAssertEqual(firstMessage.placement, 1020)
                        XCTAssertFalse(firstMessage.persists)
                        XCTAssertFalse(firstMessage.read)
                        XCTAssertFalse(firstMessage.interacted)
                        XCTAssertEqual(firstMessage.messageTypes, ["home_nudge"])
                        XCTAssertEqual(firstMessage.title, "Well done Jacob!")
                        XCTAssertEqual(firstMessage.contentType, .text)
                        XCTAssertEqual(firstMessage.content!, .text(APIMessageResponse.Content.Text(designType: "information", footer: "Footer", header: "Header", imageURL: nil, text: "Some body")))
                        XCTAssertEqual(firstMessage.action?.title, "Claim Points")
                        XCTAssertEqual(firstMessage.action?.link, "frollo://dashboard/")
                        XCTAssertEqual(firstMessage.action?.openExternal, false)
                        XCTAssertEqual(firstMessage.autoDismiss, true)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMessagesSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_invalid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint, preemptiveRefreshTime: 180)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchMessages { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 35)
                    
                    let message = response[1]
                    XCTAssertEqual(message.id, 52432)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchUnreadMessages() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint, preemptiveRefreshTime: 180)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchUnreadMessages { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 7)
                    
                    if let firstMessage = response.first {
                        XCTAssertEqual(firstMessage.id, 52473)
                        XCTAssertEqual(firstMessage.event, "DEMO_START")
                        XCTAssertEqual(firstMessage.userEventID, 50581)
                        XCTAssertEqual(firstMessage.placement, 1020)
                        XCTAssertFalse(firstMessage.persists)
                        XCTAssertFalse(firstMessage.read)
                        XCTAssertFalse(firstMessage.interacted)
                        XCTAssertEqual(firstMessage.messageTypes, ["home_nudge"])
                        XCTAssertEqual(firstMessage.title, "Well done Jacob!")
                        XCTAssertEqual(firstMessage.contentType, .html)
                        XCTAssertEqual(firstMessage.content!, APIMessageResponse.Content.html(APIMessageResponse.Content.HTML(footer: nil, header: nil, main: "<html></html>")))
                        XCTAssertEqual(firstMessage.action?.title, "Claim Points")
                        XCTAssertEqual(firstMessage.action?.link, "frollo://dashboard/")
                        XCTAssertEqual(firstMessage.action?.openExternal, false)
                        XCTAssertEqual(firstMessage.autoDismiss, true)
                    }
                    
                    for message in response {
                        XCTAssertFalse(message.read)
                    }
            }
            
            expectation1.fulfill()
        }
        
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMessageByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let id: Int64 = 12345
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint, preemptiveRefreshTime: 180)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchMessage(messageID: id) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let message):
                    XCTAssertEqual(message.id, id)
                    XCTAssertEqual(message.event, "TEST_WEBVIEW_AUTH")
                    XCTAssertEqual(message.userEventID, 47936)
                    XCTAssertEqual(message.placement, 1)
                    XCTAssertTrue(message.persists)
                    XCTAssertFalse(message.read)
                    XCTAssertFalse(message.interacted)
                    XCTAssertEqual(message.messageTypes, ["home_nudge"])
                    XCTAssertEqual(message.title, "Test WebView Auth")
                    XCTAssertEqual(message.contentType, .text)
                    XCTAssertEqual(message.content!, .text(APIMessageResponse.Content.Text(designType: "information", footer: "Footer", header: "Header", imageURL: nil, text: "Some body")))
                    XCTAssertNil(message.action?.title)
                    XCTAssertEqual(message.action?.link, "https://example.com")
                    XCTAssertEqual(message.action?.openExternal, false)
                    XCTAssertEqual(message.autoDismiss, true)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateMessage() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        let id: Int64 = 12345
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint, preemptiveRefreshTime: 180)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let request = APIMessageUpdateRequest(interacted: false, read: true)
        service.updateMessage(messageID: id, request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, id)
            }

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)
    }

}
