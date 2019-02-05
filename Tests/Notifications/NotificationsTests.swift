//
//  NotificationsTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
    }
    
    func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }

    func testRegisteringPushNotificationToken() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + DeviceEndpoint.device.path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        let network = Network(serverURL: url, keychain: keychain)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: nil)
        let events = Events(network: network)
        let messages = Messages(database: database, network: network)
        
        let notifications = Notifications(authentication: authentication, events: events, messages: messages)
        
        authentication.loggedIn = true
        
        let tokenString = "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad"
        let tokenData = dataWithHexString(hex: tokenString)
        
        notifications.registerPushNotificationToken(tokenData)
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testHandlingPushNotificationEvent() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        let network = Network(serverURL: url, keychain: keychain)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: nil)
        let events = Events(network: network)
        let messages = Messages(database: database, network: network)
        
        let notifications = Notifications(authentication: authentication, events: events, messages: messages)
        
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
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: 98765).path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let preferences = Preferences(path: path)
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        let network = Network(serverURL: url, keychain: keychain)
        let authentication = Authentication(database: database, network: network, preferences: preferences, delegate: nil)
        let events = Events(network: network)
        let messages = Messages(database: database, network: network)
        
        let notifications = Notifications(authentication: authentication, events: events, messages: messages)
        
        let jsonURL = Bundle(for: NotificationsTests.self).url(forResource: "notification_message", withExtension: "json")!
        let payloadData = try! Data(contentsOf: jsonURL)
        
        let json = try! JSONSerialization.jsonObject(with: payloadData, options: .allowFragments) as! [String: Any]
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            notifications.handlePushNotification(userInfo: json)
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
