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
    var keychain: Keychain {
        return Keychain.validNetworkKeychain(service: keychainService)
    }
    
    var networkAuthenticator: NetworkAuthenticator {
        return NetworkAuthenticator(authorizationEndpoint: self.config.authorizationEndpoint, serverEndpoint: self.config.serverEndpoint, tokenEndpoint: self.config.tokenEndpoint, keychain: keychain)
    }
    
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

extension DatabaseIdentifying where Self: KeychainServiceIdentifying, Self: XCTestCase {
    func authentication(loggedIn: Bool) -> Authentication {
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
    
    @discardableResult
    func connect(endpoint: Endpoint, toResourceWithName name: String, addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        var finalHeaders = headers ?? [:]
        finalHeaders[HTTPHeader.contentType.rawValue] = "application/json"
        let response: OHHTTPStubsResponseBlock = { _ in fixture(filePath: Bundle(for: type(of: self)).path(forResource: name, ofType: "json")!, status: Int32(statusCode), headers: finalHeaders) }
        return stub(condition: isHost(self.config.serverEndpoint.host!) && isPath("/" + endpoint.path), response: response)
    }
    
    @discardableResult
    func connect(endpoint: Endpoint, addingData data: Data = Data(), addingStatusCode statusCode: Int = 200, addingHeaders headers: [String: String]? = nil) -> OHHTTPStubsDescriptor {
        var finalHeaders = headers ?? [:]
        finalHeaders[HTTPHeader.contentType.rawValue] = "application/json"
        let response: OHHTTPStubsResponseBlock = { _ in OHHTTPStubsResponse(data: data, statusCode: Int32(statusCode), headers: finalHeaders) }
        return stub(condition: isHost(self.config.serverEndpoint.host!) && isPath("/" + endpoint.path), response: response)
    }
}
