//
// Copyright © 2019 Frollo. All rights reserved.
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

#if CORE && os(iOS) 
import AppAuthCore
#else
import AppAuth
#endif

class OAuthErrorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAccessDeniedError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.accessDenied.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .accessDenied)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.AccessDenied"))
    }
    
    func testClientError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.clientError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .clientError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.ClientError"))
    }
    
    func testInvalidClientError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidClient.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidClient)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidClient"))
    }
    
    func testInvalidClientMetadataError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidClientMetadata.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidClientMetadata)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidClientMetadata"))
    }
    
    func testInvalidGrantError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidGrant.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidGrant)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidGrant"))
    }
    
    func testInvalidRedirectURIError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidRedirectURI.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidRedirectURI)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidRedirectURI"))
    }
    
    func testInvalidRequestError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidRequest.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidRequest)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidRequest"))
    }
    
    func testInvalidScopeError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidScope.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidScope)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidScope"))
    }
   
    func testUnauthorizedClientError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.unauthorizedClient.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unauthorizedClient)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UnauthorizedClient"))
    }
    
    func testUnsupportedGrantTypeError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.unsupportedGrantType.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unsupportedGrantType)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UnsupportedGrantType"))
    }
    
    func testUnsupportedResponseTypeError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.unsupportedResponseType.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unsupportedResponseType)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UnsupportedResponseType"))
    }
    
    func testBrowserError() {
        let error = NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.safariOpenError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .browserError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.BrowserError"))
    }
    
    func testNetworkError() {
        let error = NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.networkError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .networkError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.NetworkError"))
    }
    
    func testServerError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.serverError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .serverError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.ServerError"))
    }
    
    func testUserCancelledError() {
        let error = OIDErrorUtilities.error(with: .userCanceledAuthorizationFlow, underlyingError: nil, description: nil) as NSError
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .userCancelled)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UserCancelled"))
    }
    
    func testOtherAuthorisationError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: -0xF000, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .otherAuthorization)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.OtherAuthorisation"))
    }
    
    func testUnknownError() {
        let error = NSError(domain: "Unknown", code: -1, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unknown)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.Unknown"))
    }

}
