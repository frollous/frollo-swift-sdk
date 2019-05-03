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

protocol NetworkAuthenticatorIdentifying {
    var networkAuthenticator: NetworkAuthenticator { get }
}

extension KeychainServiceIdentifying where Self: XCTestCase {
    var keychain: Keychain {
        return Keychain.validNetworkKeychain(service: keychainService)
    }
}

extension NetworkAuthenticatorIdentifying where Self: XCTestCase, Self: KeychainServiceIdentifying {
    
    var network: Network {
        return Network(serverEndpoint: self.config.serverEndpoint, networkAuthenticator: networkAuthenticator)
    }
    
    var service: APIService {
        return APIService(serverEndpoint: self.config.serverEndpoint, network: network)
    }
    
    var authService: OAuthService {
        return OAuthService(authorizationEndpoint: config.authorizationEndpoint, tokenEndpoint: config.tokenEndpoint, redirectURL: config.redirectURL, network: network)
    }
}

extension DatabaseIdentifying where Self: KeychainServiceIdentifying, Self: NetworkAuthenticatorIdentifying, Self: XCTestCase {
    func authentication(loggedIn: Bool = false) -> Authentication {
        let authentication = Authentication(database: database, clientID: self.config.clientID, domain: self.config.serverEndpoint.host!, networkAuthenticator: networkAuthenticator, authService: authService, service: service, preferences: preferences, delegate: nil)
        authentication.loggedIn = loggedIn
        return authentication
    }
    
    func aggregation(loggedIn: Bool) -> Aggregation {
        return Aggregation(database: database, service: service, authentication: authentication(loggedIn: loggedIn))
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
