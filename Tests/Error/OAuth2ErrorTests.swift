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

class OAuth2ErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    func errorJSONNamed(_ fileName: String) -> Data {
        let errorJSONPath = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: errorJSONPath)
    }
    
    // MARK: - Server Error Tests
    
    func tesOAuthServerError() {
        let errorJSON = errorJSONNamed("error_oauth2_server")
        
        let error = OAuth2Error(response: errorJSON)
        
        XCTAssertEqual(error.debugDescription, "Authorization server not configured with default connection.")
        XCTAssertEqual(error.type, "server_error")
        
    }
    
    // MARK: - Invalid Request Tests
    
    func testOAuthInvalidRequestError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_request")
        
        let error = OAuth2Error(response: errorJSON)
        
        XCTAssertEqual(error.debugDescription, "Request was missing the 'redirect_uri' parameter.")
        XCTAssertEqual(error.type, "invalid_request")
        XCTAssertEqual(error.errorUri, "See the full API docs at https://authorization-server.com/docs/access_token")
        
    }
    
    // MARK: - Invalid Client Tests
    
    func testOAuthInvalidClientError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_client")
        
        let error = OAuth2Error(response: errorJSON)
        
        XCTAssertEqual(error.debugDescription, "Invalid client request")
        XCTAssertEqual(error.type, "invalid_client")
        
    }
    
    // MARK: - Invalid Grant Tests
    
    func testOAuthInvalidGrantError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_grant")
        
        let error = OAuth2Error(response: errorJSON)
        
        XCTAssertEqual(error.debugDescription, "Invalid Grant Request")
        XCTAssertEqual(error.type, "invalid_grant")
        
    }
    
    // MARK: - Invalid Scope Tests
    
    func testOAuthInvalidScopeError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_scope")
        
        let error = OAuth2Error(response: errorJSON)
        
        XCTAssertEqual(error.debugDescription, "Invalid scope request.")
        XCTAssertEqual(error.type, "invalid_scope")
        
    }
    
    // MARK: - Invalid Unaothorized Client Tests
    
    func testOAuthUnauthorizedClientError() {
        let errorJSON = errorJSONNamed("error_oauth2_unauthorized_client")
        
        let error = OAuth2Error(response: errorJSON)
        
        XCTAssertEqual(error.debugDescription, "Unauthorized client request.")
        XCTAssertEqual(error.type, "unauthorized_client")
        XCTAssertEqual(error.errorUri, "See the full API docs at https://authorization-server.com/docs/access_token")
        
    }
}
