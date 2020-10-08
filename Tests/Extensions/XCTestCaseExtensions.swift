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
    
    func defaultAuthentication(keychain: Keychain, loggedIn: Bool = true) -> Authentication {
        let mockAuthentication = MockAuthentication(valid: loggedIn)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        return authentication
    }
    
    func defaultAuthentication(keychain: Keychain, handler: AuthenticationDataSource & AuthenticationDelegate) -> Authentication {
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = handler
        authentication.delegate = handler
        return authentication
    }
    
    func defaultOAuth2Authentication(loggedIn: Bool = false) -> OAuth2Authentication {
        let keychain = defaultKeychain(isNetwork: false)
        return defaultOAuth2Authentication(keychain: keychain, loggedIn: loggedIn)
    }
    
    func defaultOAuth2Authentication(keychain: Keychain, loggedIn: Bool = false) -> OAuth2Authentication {
        let authentication = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: self.config.serverEndpoint, authentication: authentication)
        let authService = defaultAuthService(keychain: keychain, network: network)
        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = loggedIn
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        return oAuth2Authentication
    }
    
    func defaultNetwork(keychain: Keychain, loggedIn: Bool = true) -> Network {
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: loggedIn)
        return defaultNetwork(keychain: keychain, authentication: authentication)
    }
    
    func defaultNetwork(keychain: Keychain, authentication: Authentication) -> Network {
        return Network(serverEndpoint: self.config.serverEndpoint, authentication: authentication)
    }
    
    func defaultService(keychain: Keychain, loggedIn: Bool = true) -> APIService {
        return APIService(serverEndpoint: self.config.serverEndpoint, network: defaultNetwork(keychain: keychain, loggedIn: loggedIn))
    }
    
    func defaultService(keychain: Keychain, authentication: Authentication) -> APIService {
        let network = defaultNetwork(keychain: keychain, authentication: authentication)
        return APIService(serverEndpoint: self.config.serverEndpoint, network: network)
    }
    
    func defaultAuthService(keychain: Keychain) -> OAuth2Service {
        return defaultAuthService(keychain: keychain, network: defaultNetwork(keychain: keychain))
    }
    
    func defaultAuthService(keychain: Keychain, network: Network) -> OAuth2Service {
        return OAuth2Service(authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint, tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint, redirectURL: FrolloSDKConfiguration.redirectURL, revokeURL: FrolloSDKConfiguration.revokeTokenEndpoint, network: network)
    }
}

extension DatabaseIdentifying where Self: KeychainServiceIdentifying, Self: XCTestCase {
    
    func aggregation(loggedIn: Bool = false) -> Aggregation {
        let keychain = defaultKeychain(isNetwork: true)
        return aggregation(keychain: keychain, loggedIn: loggedIn)
    }
    
    func aggregation(keychain: Keychain, loggedIn: Bool) -> Aggregation {
        return Aggregation(database: database, service: defaultService(keychain: keychain, loggedIn: loggedIn))
    }
    
    // MARK: - Bills
    func defaultBills() -> Bills {
        let keychain = defaultKeychain(isNetwork: true)
        return defaultBills(keychain: keychain)
    }
    
    func defaultBills(keychain: Keychain) -> Bills {
        return Bills(database: database, service: defaultService(keychain: keychain), aggregation: aggregation(keychain: keychain, loggedIn: true))
    }
    
    // MARK: - User
    
    func defaultUser(loggedIn: Bool = true) -> UserManagement {
        let keychain = defaultKeychain(isNetwork: true)
        return defaultUser(keychain: keychain, loggedIn: loggedIn)
    }
    
    func defaultUser(keychain: Keychain, loggedIn: Bool = true) -> UserManagement {
        let authentication = defaultAuthentication(keychain: keychain, loggedIn: loggedIn)
        return defaultUser(keychain: keychain, authentication: authentication, loggedIn: loggedIn)
    }
    
    func defaultUser(keychain: Keychain, delegate: Frollo? = nil, loggedIn: Bool = true) -> UserManagement {
        let authentication  = defaultAuthentication(keychain: keychain, loggedIn: loggedIn)
        return UserManagement(database: database, service: defaultService(keychain: keychain, authentication: authentication), clientID: config.clientID, authentication: nil, preferences: preferences, delegate: delegate)
    }
    
    func defaultUser(keychain: Keychain, authentication: Authentication, delegate: Frollo? = nil, loggedIn: Bool = true) -> UserManagement {
        return UserManagement(database: database, service: defaultService(keychain: keychain, authentication: authentication), clientID: config.clientID, authentication: nil, preferences: preferences, delegate: delegate)
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
    
    enum Method {
        case post
        case put
        case get
        
        var condition: OHHTTPStubsTestBlock {
            switch self {
            case .post:
                return isMethodPOST()
            case .put:
                return isMethodPUT()
            case .get:
                return isMethodGET()
            }
        }
    }
    
    @discardableResult
    func connect(endpoint: String, method: Method? = nil, toResourceWithName name: String, addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        return connect(host: serverEndpointHost, endpoint: endpoint, method: method, toResourceWithName: name, addingStatusCode: statusCode, addingHeaders: headers)
    }
    
    @discardableResult
    func connect(endpoint: String, method: Method? = nil, addingData data: Data = Data(), addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        return connect(host: serverEndpointHost, endpoint: endpoint, method: method, addingData: data, addingStatusCode: statusCode, addingHeaders: headers)
    }
    
    @discardableResult
    func connect(host: String, endpoint: String, method: Method? = nil, toResourceWithName name: String, addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        var finalHeaders = headers ?? [:]
        finalHeaders[HTTPHeader.contentType.rawValue] = "application/json"
        let response: OHHTTPStubsResponseBlock = { _ in fixture(filePath: Bundle(for: type(of: self)).path(forResource: name, ofType: "json")!, status: Int32(statusCode), headers: finalHeaders) }
        var condition = isHost(host) && isPath(endpoint)
        if let method = method {
            condition = condition && method.condition
        }
        return stub(condition: condition, response: response)
    }
    
    @discardableResult
    func connect(host: String, endpoint: String, method: Method? = nil, addingData data: Data = Data(), addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        var finalHeaders = headers ?? [:]
        finalHeaders[HTTPHeader.contentType.rawValue] = "application/json"
        let response: OHHTTPStubsResponseBlock = { _ in OHHTTPStubsResponse(data: data, statusCode: Int32(statusCode), headers: finalHeaders) }
        var condition = isHost(host) && isPath(endpoint)
        if let method = method {
            condition = condition && method.condition
        }
        return stub(condition: condition, response: response)
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
