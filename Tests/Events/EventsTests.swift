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

class EventsTests: XCTestCase {
    
    let keychainService = "EventsTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testTriggerEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + EventsEndpoint.events.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let database = Database(path: tempFolderPath())
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let preferences = Preferences(path: tempFolderPath())
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, serverURL: config.serverEndpoint, networkAuthenticator: networkAuthenticator, authService: authService, preferences: preferences, delegate: nil)
        authentication.loggedIn = true
        let events = Events(service: service, authentication: authentication)
        
        events.triggerEvent("TEST_EVENT", after: 5) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTriggerEventFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + EventsEndpoint.events.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let database = Database(path: tempFolderPath())
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let preferences = Preferences(path: tempFolderPath())
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, serverURL: config.serverEndpoint, networkAuthenticator: networkAuthenticator, authService: authService, preferences: preferences, delegate: nil)
        authentication.loggedIn = false
        let events = Events(service: service, authentication: authentication)
        
        events.triggerEvent("TEST_EVENT", after: 5) { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .loggedOut)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandleEventHandled() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let database = Database(path: tempFolderPath())
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let preferences = Preferences(path: tempFolderPath())
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, serverURL: config.serverEndpoint, networkAuthenticator: networkAuthenticator, authService: authService, preferences: preferences, delegate: nil)
        authentication.loggedIn = true
        let events = Events(service: service, authentication: authentication)
        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let database = Database(path: tempFolderPath())
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let preferences = Preferences(path: tempFolderPath())
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, serverURL: config.serverEndpoint, networkAuthenticator: networkAuthenticator, authService: authService, preferences: preferences, delegate: nil)
        authentication.loggedIn = true
        let events = Events(service: service, authentication: authentication)
        
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
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let database = Database(path: tempFolderPath())
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let preferences = Preferences(path: tempFolderPath())
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
        
        let authentication = Authentication(database: database, clientID: config.clientID, serverURL: config.serverEndpoint, networkAuthenticator: networkAuthenticator, authService: authService, preferences: preferences, delegate: nil)
        authentication.loggedIn = true
        let events = Events(service: service, authentication: authentication)
        
        let notificationUpdated = NotificationPayload.testTransactionUpdatedData()
        
        events.handleEvent("T_UPDATED", notification: notificationUpdated) { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }

}
