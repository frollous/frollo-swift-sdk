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
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.AccessDenied") + "\n\norg.openid.appauth.oauth_authorization -4: Error Domain=org.openid.appauth.oauth_authorization Code=-4 \"(null)\"")
    }
    
    func testClientError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.clientError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .clientError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.ClientError") + "\n\norg.openid.appauth.oauth_authorization -61439: Error Domain=org.openid.appauth.oauth_authorization Code=-61439 \"(null)\"")
    }
    
    func testInvalidClientError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidClient.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidClient)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidClient") + "\n\norg.openid.appauth.oauth_authorization -9: Error Domain=org.openid.appauth.oauth_authorization Code=-9 \"(null)\"")
    }
    
    func testInvalidClientMetadataError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidClientMetadata.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidClientMetadata)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidClientMetadata") + "\n\norg.openid.appauth.oauth_authorization -13: Error Domain=org.openid.appauth.oauth_authorization Code=-13 \"(null)\"")
    }
    
    func testInvalidGrantError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidGrant.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidGrant)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidGrant") + "\n\norg.openid.appauth.oauth_authorization -10: Error Domain=org.openid.appauth.oauth_authorization Code=-10 \"(null)\"")
    }
    
    func testInvalidRedirectURIError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidRedirectURI.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidRedirectURI)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidRedirectURI") + "\n\norg.openid.appauth.oauth_authorization -12: Error Domain=org.openid.appauth.oauth_authorization Code=-12 \"(null)\"")
    }
    
    func testInvalidRequestError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidRequest.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidRequest)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidRequest") + "\n\norg.openid.appauth.oauth_authorization -2: Error Domain=org.openid.appauth.oauth_authorization Code=-2 \"(null)\"")
    }
    
    func testInvalidScopeError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.invalidScope.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .invalidScope)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.InvalidScope") + "\n\norg.openid.appauth.oauth_authorization -6: Error Domain=org.openid.appauth.oauth_authorization Code=-6 \"(null)\"")
    }
   
    func testUnauthorizedClientError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.unauthorizedClient.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unauthorizedClient)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UnauthorizedClient") + "\n\norg.openid.appauth.oauth_authorization -3: Error Domain=org.openid.appauth.oauth_authorization Code=-3 \"(null)\"")
    }
    
    func testUnsupportedGrantTypeError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.unsupportedGrantType.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unsupportedGrantType)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UnsupportedGrantType") + "\n\norg.openid.appauth.oauth_authorization -11: Error Domain=org.openid.appauth.oauth_authorization Code=-11 \"(null)\"")
    }
    
    func testUnsupportedResponseTypeError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.unsupportedResponseType.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unsupportedResponseType)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UnsupportedResponseType") + "\n\norg.openid.appauth.oauth_authorization -5: Error Domain=org.openid.appauth.oauth_authorization Code=-5 \"(null)\"")
    }
    
    func testBrowserError() {
        let error = NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.safariOpenError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .browserError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.BrowserError") + "\n\norg.openid.appauth.general -9: Error Domain=org.openid.appauth.general Code=-9 \"(null)\"")
    }
    
    func testNetworkError() {
        let error = NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.networkError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .networkError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.NetworkError") + "\n\norg.openid.appauth.general -5: Error Domain=org.openid.appauth.general Code=-5 \"(null)\"")
    }
    
    func testServerError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuth.serverError.rawValue, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .serverError)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.ServerError") + "\n\norg.openid.appauth.oauth_authorization -7: Error Domain=org.openid.appauth.oauth_authorization Code=-7 \"(null)\"")
    }
    
    func testUserCancelledError() {
        let error = OIDErrorUtilities.error(with: .userCanceledAuthorizationFlow, underlyingError: nil, description: nil) as NSError
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .userCancelled)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.UserCancelled") + "\n\norg.openid.appauth.general -3: Error Domain=org.openid.appauth.general Code=-3 \"(null)\"")
    }
    
    func testOtherAuthorisationError() {
        let error = NSError(domain: OIDOAuthAuthorizationErrorDomain, code: -0xF000, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .otherAuthorization)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.OtherAuthorisation") + "\n\norg.openid.appauth.oauth_authorization -61440: Error Domain=org.openid.appauth.oauth_authorization Code=-61440 \"(null)\"")
    }
    
    func testUnknownError() {
        let error = NSError(domain: "Unknown", code: -1, userInfo: nil)
        
        let authError = OAuth2Error(error: error)
        XCTAssertEqual(authError.type, .unknown)
        XCTAssertEqual(authError.localizedDescription, Localization.string("Error.OAuth.Unknown") + "\n\nUnknown -1: Error Domain=Unknown Code=-1 \"(null)\"")
    }

}
