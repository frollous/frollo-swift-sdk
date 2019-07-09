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
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testCustomAuthentication() {
        class CustomAuthentication: Authentication {
            
            private var tokenIndex = 0
            private let validTokens = ["AccessToken001", "AccessToken002", "AccessToken003"]
            
            var loggedIn = false
            
            var delegate: AuthenticationDelegate?
            var tokenDelegate: AuthenticationTokenDelegate?
            
            func login() {
                loggedIn = true
                
                tokenDelegate?.saveAccessTokens(accessToken: validTokens[tokenIndex], expiry: Date().addingTimeInterval(3600))
            }
            
            func refreshTokens(completion: FrolloSDKCompletionHandler?) {
                if tokenIndex < 2 {
                    tokenIndex += 1
                } else {
                    tokenIndex = 0
                }
                
                tokenDelegate?.saveAccessTokens(accessToken: validTokens[tokenIndex], expiry: Date().addingTimeInterval(3600))
                
                completion?(.success)
            }
            
            func resumeAuthentication(url: URL) -> Bool {
                return false
            }
            
            func logout() {
                reset()
            }
            
            func reset() {
                loggedIn = false
                
                tokenIndex = 0
            }
            
        }
        
        let expectation1 = expectation(description: "SDK Setup")
        let expectation2 = expectation(description: "Refresh Tokens")
        
        let authentication = CustomAuthentication()
        
        let serverURL = URL(string: "https://api.example.com")!
        let config = FrolloSDKConfiguration(authenticationType: .custom(authentication: authentication),
                                            serverEndpoint: serverURL)
        
        let sdk = FrolloSDK()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        XCTAssert(authentication === sdk.authentication)
        XCTAssertEqual(sdk.authentication.loggedIn, false)
        
        authentication.login()
        
        XCTAssertEqual(sdk.authentication.loggedIn, true)
        XCTAssertEqual(sdk.network.authenticator.accessToken, "AccessToken001")
        
        sdk.authentication.refreshTokens { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(sdk.network.authenticator.accessToken, "AccessToken002")
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
    }
    
}
