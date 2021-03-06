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

class EventsRequestTests: XCTestCase, KeychainServiceIdentifying {
    
    let keychainService = "EventsRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testCreateEvent() {
        let expectation1 = expectation(description: "Network Request")
        
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
        
        let request = APIEventCreateRequest(delayMinutes: 0, event: "EVENT_TEST")
        
        service.createEvent(request: request) { (result) in
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

    func testCreateEventFail() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + EventsEndpoint.events.path)) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: "{}".data(using: .utf8)!, statusCode: 201, headers: nil)
        }
        
        let keychain = defaultKeychain(isNetwork: true)
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let service = invalidService(keychain: keychain)
        
        let request = APIEventCreateRequest(delayMinutes: 0, event: "EVENT_TEST")
        
        service.createEvent(request: request) { (result) in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error is DataError)
                if let error = error as? DataError {
                    XCTAssertEqual(error.type, DataError.DataErrorType.api)
                    XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                }
            case .success:
                XCTFail("Invalid service throw Error when encoding")
            }            
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
}
