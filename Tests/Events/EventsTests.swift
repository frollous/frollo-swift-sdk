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
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class EventsTests: XCTestCase {
    
    let keychainService = "EventsTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testTriggerEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + EventsEndpoint.events.path)) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: "{}".data(using: .utf8)!, statusCode: 201, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
        
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
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + EventsEndpoint.events.path)) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
        
        events.triggerEvent("TEST_EVENT", after: 5) { (result) in
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
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandleEventHandled() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
        
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
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
        
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
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
        
        let notificationUpdated = NotificationPayload.testTransactionUpdatedData()
        
        events.handleEvent("T_UPDATED", notification: notificationUpdated) { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }
    
    func testHandlebudgetPeriodReadyEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Budgets.currentBudgetPeriodReadyNotification, object: nil) { (notification) -> Bool in
            return true
        }
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
                
        events.handleEvent("B_CURRENT_PERIOD_READY") { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }
    
    func testHandleOnboardingEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: UserManagement.onboardingStepCompletedNotification, object: nil) { (notification) -> Bool in
            
            XCTAssertNotNil(notification.userInfo)
            
            guard let onboardingStep = notification.userInfo?[UserManagement.onboardingEventKey] as? String
                else {
                    XCTFail()
                    return true
            }
            
            XCTAssertEqual(onboardingStep, "account_opening")
            
            return true
        }
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let events = Events(service: service)
                
        events.handleEvent("ONBOARDING_STEP_COMPLETED", notification: NotificationPayload.testOnboardingData()) { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }

    func testHandleProviderAccountLinkedEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountLinkedNotification, object: nil) { (notification) -> Bool in
            return true
        }

        let config = FrolloSDKConfiguration.testConfig()

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let events = Events(service: service)

        events.handleEvent("PA_LINKED") { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            expectation1.fulfill()
        }

        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }

    func testHandleProviderAccountLinkingFailedEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountLinkingFailedNotification, object: nil) { (notification) -> Bool in
            return true
        }

        let config = FrolloSDKConfiguration.testConfig()

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let events = Events(service: service)

        events.handleEvent("PA_FAILED") { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            expectation1.fulfill()
        }

        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }

    func testHandleMFARequestEvent() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountMFARequiredNotification, object: nil) { (notification) -> Bool in
            return true
        }

        let config = FrolloSDKConfiguration.testConfig()

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let events = Events(service: service)

        events.handleEvent("PA_MFA") { (handled, error) in
            XCTAssertTrue(handled)
            XCTAssertNil(error)
            expectation1.fulfill()
        }

        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }
}
