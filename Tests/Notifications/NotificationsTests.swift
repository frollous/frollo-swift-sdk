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

class NotificationsTests: XCTestCase {
    
    let keychainService = "NotificationsTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testRegisteringPushNotificationToken() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + DeviceEndpoint.device.path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
        let messages = Messages(database: database, service: service)
        let userManagement = UserManagement(database: database, service: service, clientID: config.clientID, authentication: nil, preferences: preferences, delegate: nil)
        
        let notifications = Notifications(events: events, messages: messages, userManagement: userManagement)
        
        let tokenString = "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
        let tokenData = Data.dataWithHexString(hex: tokenString)
        
        notifications.handlePushNotificationToken(tokenData)
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testHandlingPushNotificationEvent() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let events = Events(service: service)
        let messages = Messages(database: database, service: service)
        let userManagement = UserManagement(database: database, service: service, clientID: config.clientID, authentication: nil, preferences: preferences, delegate: nil)
        
        let notifications = Notifications(events: events, messages: messages, userManagement: userManagement)
        
        let jsonURL = Bundle(for: NotificationsTests.self).url(forResource: "notification_event", withExtension: "json")!
        let payloadData = try! Data(contentsOf: jsonURL)
        
        let json = try! JSONSerialization.jsonObject(with: payloadData, options: .allowFragments) as! [String: Any]
        
        notifications.handlePushNotification(userInfo: json)
        
        // TODO: - Check Event Callback delegate
        expectation1.fulfill()
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandlingPushNotificationMessage() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: 98765).path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let events = Events(service: service)
        let messages = Messages(database: database, service: service)
        let userManagement = UserManagement(database: database, service: service, clientID: config.clientID, authentication: nil, preferences: preferences, delegate: nil)
        
        let notifications = Notifications(events: events, messages: messages, userManagement: userManagement)
        
        let jsonURL = Bundle(for: NotificationsTests.self).url(forResource: "notification_message", withExtension: "json")!
        let payloadData = try! Data(contentsOf: jsonURL)
        
        let json = try! JSONSerialization.jsonObject(with: payloadData, options: .allowFragments) as! [String: Any]
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            notifications.handlePushNotification(userInfo: json)
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }

}
