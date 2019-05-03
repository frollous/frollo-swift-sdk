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
import CoreData
import OHHTTPStubs

protocol KeychainServiceIdentifying {
    var keychainService: String { get }
}

protocol DatabaseIdentifying {
    var database: Database { get }
}

extension DatabaseIdentifying {
    var context: NSManagedObjectContext {
        return database.viewContext
    }
}

extension KeychainServiceIdentifying where Self: XCTestCase {
    
    func defaultKeychain(isNetwork: Bool) -> Keychain {
        switch isNetwork {
        case false:
            return Keychain(service: keychainService)
        case true:
            return Keychain.validNetworkKeychain(service: keychainService)
        }
    }
    
    func defaultNetworkAuthenticator(keychain: Keychain) -> NetworkAuthenticator {
        return NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
    }
    
    func defaultNetwork(keychain: Keychain) -> Network {
        let authenticator = defaultNetworkAuthenticator(keychain: keychain)
        return defaultNetwork(keychain: keychain, networkAuthenticator: authenticator)
    }
    
    func defaultNetwork(keychain: Keychain, networkAuthenticator: NetworkAuthenticator) -> Network {
        return Network(serverEndpoint: self.config.serverEndpoint, networkAuthenticator: networkAuthenticator)
    }
    
    func defaultService(keychain: Keychain) -> APIService {
        return APIService(serverEndpoint: self.config.serverEndpoint, network: defaultNetwork(keychain: keychain))
    }
    
    func defaultService(keychain: Keychain, networkAuthenticator: NetworkAuthenticator) -> APIService {
        let network = defaultNetwork(keychain: keychain, networkAuthenticator: networkAuthenticator)
        return APIService(serverEndpoint: self.config.serverEndpoint, network: network)
    }
    
    func defaultAuthService(keychain: Keychain) -> OAuthService {
        return OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: defaultNetwork(keychain: keychain))
    }
}

extension DatabaseIdentifying where Self: KeychainServiceIdentifying, Self: XCTestCase {
    
    func defaultAuthentication(loggedIn: Bool = false) -> Authentication {
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        return defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: loggedIn)
    }
    
    func defaultAuthentication(keychain: Keychain, networkAuthenticator: NetworkAuthenticator, loggedIn: Bool = false) -> Authentication {
        let authentication = Authentication(database: database, clientID: self.config.clientID, domain: self.config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: defaultAuthService(keychain: keychain), service: defaultService(keychain: keychain, networkAuthenticator: networkAuthenticator), preferences: preferences, delegate: nil)
        authentication.loggedIn = loggedIn
        return authentication
    }
    
    func defaultAuthentication(keychain: Keychain, loggedIn: Bool = false) -> Authentication {
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        return defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: loggedIn)
    }
    
    func aggregation(keychain: Keychain, loggedIn: Bool) -> Aggregation {
        return Aggregation(database: database, service: defaultService(keychain: keychain), authentication: defaultAuthentication(keychain: keychain, networkAuthenticator: defaultNetworkAuthenticator(keychain: keychain), loggedIn: loggedIn))
    }
}

extension XCTestCase {
    var config: FrolloSDKConfiguration {
        return .testConfig()
    }
    
    var preferences: Preferences {
        return Preferences(path: tempFolderPath())
    }
}

extension XCTestCase {
    var serverEndpointHost: String {
        return config.serverEndpoint.host!
    }
    
    var tokenEndpointHost: String {
        return config.tokenEndpoint.host!
    }
}

extension XCTestCase {
    
    @discardableResult
    func connect(endpoint: String, toResourceWithName name: String, addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        return connect(host: serverEndpointHost, endpoint: endpoint, toResourceWithName: name, addingStatusCode: statusCode, addingHeaders: headers)
    }
    
    @discardableResult
    func connect(endpoint: String, addingData data: Data = Data(), addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        return connect(host: serverEndpointHost, endpoint: endpoint, addingData: data, addingStatusCode: statusCode, addingHeaders: headers)
    }
    
    @discardableResult
    func connect(host: String, endpoint: String, toResourceWithName name: String, addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        var finalHeaders = headers ?? [:]
        finalHeaders[HTTPHeader.contentType.rawValue] = "application/json"
        let response: OHHTTPStubsResponseBlock = { _ in fixture(filePath: Bundle(for: type(of: self)).path(forResource: name, ofType: "json")!, status: Int32(statusCode), headers: finalHeaders) }
        return stub(condition: isHost(host) && isPath(endpoint), response: response)
    }
    
    @discardableResult
    func connect(host: String, endpoint: String, addingData data: Data = Data(), addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        var finalHeaders = headers ?? [:]
        finalHeaders[HTTPHeader.contentType.rawValue] = "application/json"
        let response: OHHTTPStubsResponseBlock = { _ in OHHTTPStubsResponse(data: data, statusCode: Int32(statusCode), headers: finalHeaders) }
        return stub(condition: isHost(host) && isPath(endpoint), response: response)
    }
}

extension String {
    func prefixed(with string: String) -> String {
        return "\(string)\(self)"
    }
    
    var prefixedWithSlash: String {
        return self.prefixed(with: "/")
    }
}
