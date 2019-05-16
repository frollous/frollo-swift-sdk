//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class OAuth2AuthenticationTests: XCTestCase {
    
    private let keychainService = "NetworkAuthenticatorTestsKeychain"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testTokensPersist() {
        let keychain = Keychain(service: keychainService)
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let refreshToken = "AnExistingRefreshToken"
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
        let network =  Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        
        let authService = OAuthService(authorizationEndpoint: config.authorizationEndpoint!, tokenEndpoint: config.tokenEndpoint!, redirectURL: config.redirectURL!, network: network)
        var authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID!, redirectURL: config.redirectURL!, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        
        authentication.updateToken(refreshToken)
        
        XCTAssertEqual(keychain["refreshToken"], refreshToken)
        
        authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID!, redirectURL: config.redirectURL!, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        
        XCTAssertEqual(authentication.refreshToken, refreshToken)
    }
}
