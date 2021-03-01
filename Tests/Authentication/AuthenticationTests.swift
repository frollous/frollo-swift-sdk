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

class AuthenticationTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "AuthenticationTestsKeychain"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testCustomAuthentication() {
        let expectation1 = expectation(description: "SDK Setup")
        let expectation2 = expectation(description: "Refresh Tokens")
        
        let authenticationHandler = MockAuthentication()
        
        let serverURL = URL(string: "https://api.example.com")!
        let config = FrolloSDKConfiguration(authenticationType: .custom(authenticationDataSource: authenticationHandler, authenticationDelegate: authenticationHandler),
                                            clientID: "abc123",
                                            dataDirectory: tempFolderPath(),
                                            serverEndpoint: serverURL)
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        XCTAssert(authenticationHandler === sdk.authentication.dataSource)
        XCTAssert(authenticationHandler === sdk.authentication.delegate)
        XCTAssertNil(sdk.oAuth2Authentication)
        
        XCTAssertNotNil(authenticationHandler.accessToken)
        
        let oldToken = authenticationHandler.accessToken?.token
        
        sdk.authentication.delegate?.accessTokenExpired { (success) in
            if success {
                XCTAssertNotEqual(sdk.authentication.dataSource?.accessToken?.token, oldToken)
            } else {
                XCTFail("Mocking auth failed")
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
    }
    
}
