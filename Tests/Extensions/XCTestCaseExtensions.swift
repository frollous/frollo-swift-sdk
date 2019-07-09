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
        return NetworkAuthenticator(serverEndpoint: config.serverEndpoint, keychain: keychain)
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
        return defaultAuthService(keychain: keychain, network: defaultNetwork(keychain: keychain))
    }
    
    func defaultAuthService(keychain: Keychain, network: Network) -> OAuthService {
        return OAuthService(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
    }
}

extension DatabaseIdentifying where Self: KeychainServiceIdentifying, Self: XCTestCase {
    
    func defaultAuthentication(loggedIn: Bool = false) -> OAuth2Authentication {
        let keychain = defaultKeychain(isNetwork: false)
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        return defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: loggedIn)
    }
    
    func defaultAuthentication(keychain: Keychain, networkAuthenticator: NetworkAuthenticator, loggedIn: Bool = false) -> OAuth2Authentication {
        let network = Network(serverEndpoint: self.config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let authService = defaultAuthService(keychain: keychain, network: network)
        let authentication = OAuth2Authentication(keychain: keychain, clientID: FrolloSDKConfiguration.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil, tokenDelegate: network)
        authentication.loggedIn = loggedIn
        return authentication
    }
    
    func defaultAuthentication(keychain: Keychain, loggedIn: Bool = false) -> OAuth2Authentication {
        let networkAuthenticator = defaultNetworkAuthenticator(keychain: keychain)
        return defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: loggedIn)
    }
    
    func aggregation(loggedIn: Bool = false) -> Aggregation {
        let keychain = defaultKeychain(isNetwork: true)
        return aggregation(keychain: keychain, loggedIn: loggedIn)
    }
    
    func aggregation(keychain: Keychain, loggedIn: Bool) -> Aggregation {
        return Aggregation(database: database, service: defaultService(keychain: keychain), authentication: defaultAuthentication(keychain: keychain, networkAuthenticator: defaultNetworkAuthenticator(keychain: keychain), loggedIn: loggedIn))
    }
    
    // MARK: - Bills
    func defaultBills() -> Bills {
        let keychain = defaultKeychain(isNetwork: true)
        return defaultBills(keychain: keychain)
    }
    
    func defaultBills(keychain: Keychain) -> Bills {
        return Bills(database: database, service: defaultService(keychain: keychain), aggregation: aggregation(keychain: keychain, loggedIn: true), authentication: defaultAuthentication(keychain: keychain))
    }
    
    // MARK: - User
    
    func defaultUser(loggedIn: Bool = true) -> UserManagement {
        let keychain = defaultKeychain(isNetwork: true)
        return defaultUser(keychain: keychain, loggedIn: loggedIn)
    }
    
    func defaultUser(keychain: Keychain, loggedIn: Bool = true) -> UserManagement {
        let networkAuthenticator  = defaultNetworkAuthenticator(keychain: keychain)
        return defaultUser(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: loggedIn)
    }
    
    func defaultUser(keychain: Keychain, authentication: Authentication, loggedIn: Bool = true) -> UserManagement {
        let networkAuthenticator  = defaultNetworkAuthenticator(keychain: keychain)
        return UserManagement(database: database, service: defaultService(keychain: keychain, networkAuthenticator: networkAuthenticator), authentication: authentication, preferences: preferences, delegate: nil)
    }
    
    func defaultUser(keychain: Keychain, networkAuthenticator: NetworkAuthenticator, loggedIn: Bool = true) -> UserManagement {
        return UserManagement(database: database, service: defaultService(keychain: keychain, networkAuthenticator: networkAuthenticator), authentication: defaultAuthentication(keychain: keychain, networkAuthenticator: networkAuthenticator, loggedIn: loggedIn), preferences: preferences, delegate: nil)
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
        return FrolloSDKConfiguration.tokenEndpoint.host!
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
