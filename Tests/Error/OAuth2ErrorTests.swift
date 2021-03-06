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
        
        let error = OAuth2Error(statusCode: 400, response: errorJSON)
        
        XCTAssertEqual(error.type, .serverError)
        
    }
    
    // MARK: - Invalid Request Tests
    
    func testOAuthInvalidRequestError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_request")
        
        let error = OAuth2Error(statusCode: 400, response: errorJSON)
        
        XCTAssertEqual(error.type, .invalidRequest)
        XCTAssertEqual(error.localizedDescription, "Request was missing the 'redirect_uri' parameter.")
    }
    
    // MARK: - Invalid Client Tests
    
    func testOAuthInvalidClientError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_client")
        
        let error = OAuth2Error(statusCode: 400, response: errorJSON)
        
        XCTAssertEqual(error.type, .invalidClient)
        
    }
    
    // MARK: - Invalid Grant Tests
    
    func testOAuthInvalidGrantError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_grant")
        
        let error = OAuth2Error(statusCode: 400, response: errorJSON)
        
        XCTAssertEqual(error.type, .invalidGrant)
        
    }
    
    // MARK: - Invalid Scope Tests
    
    func testOAuthInvalidScopeError() {
        let errorJSON = errorJSONNamed("error_oauth2_invalid_scope")
        
        let error = OAuth2Error(statusCode: 400, response: errorJSON)
        
        XCTAssertEqual(error.type, .invalidScope)
        
    }
    
    // MARK: - Invalid Unaothorized Client Tests
    
    func testOAuthUnauthorizedClientError() {
        let errorJSON = errorJSONNamed("error_oauth2_unauthorized_client")
        
        let error = OAuth2Error(statusCode: 400, response: errorJSON)
        
        XCTAssertEqual(error.type, .unauthorizedClient)

        
    }
}
