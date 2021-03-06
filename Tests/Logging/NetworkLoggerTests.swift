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

import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

@testable import FrolloSDK

class NetworkLoggerTests: XCTestCase {
    
    let keychainService = "NetworkLoggerKeychainService"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testLogging() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + DeviceEndpoint.log.path)) { (request) -> HTTPStubsResponse in
            expectation1.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let logger = NetworkLogger(service: service)
        
        logger.writeMessage("Test Message", level: .error)
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
