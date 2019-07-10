//
// Copyright © 2018 Frollo. All rights reserved.
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

import Foundation

/**
 Authentication Delegate
 
 Called by the authentication class to notify other parts of the SDK of authentication changes.
 This must be implemented by all custom authentication implementations.
 */
public protocol AuthenticationDelegate: AnyObject {
    
    /**
     Notifies the SDK that authentication of the user is no longer valid and to reset itself
     
     This should be called when the user's authentication is no longer valid and no possible automated
     reauthentication can be performed. For example when a refresh token has been revoked so no more
     access tokens can be obtained.
     */
    func authenticationReset()
    
}

/**
 Authentication Token Delegate
 
 Called by the authentication class to notify other parts of the SDK of token changes.
 This must be implemented by all custom authentication implementations.
 */
public protocol AuthenticationTokenDelegate: AnyObject {
    
    /**
     Update the SDK with the latest access token
     
     Allows the SDK to cache and use the latest access token available for API requests. This should
     be called whenever the access token is refreshed or the user has authenticated and obtained a new
     access token.
     
     - parameters:
     - accessToken: Current valid access token
     - expiry: Indicates the date when the access token expires so SDK can pre-emptively request a new one
     */
    func saveAccessTokens(accessToken: String, expiry: Date)
    
}

/**
 Authentication
 
 Manages authentication, login, registration, logout and the user profile.
 */
public protocol Authentication: AnyObject {
    
    /**
     Indicates if the user is currently authorised with Frollo
     */
    var loggedIn: Bool { get }
    
    /**
     SDK delegate to be called to update SDK about authentication events. SDK sets this as part of setup
     */
    var delegate: AuthenticationDelegate? { get set }
    
    /**
     SDK delegate to be called to update SDK about token change events. SDK sets this as part of setup
     */
    var tokenDelegate: AuthenticationTokenDelegate? { get set }
    
    /**
     Refresh Access Token
     
     Forces a refresh of the access tokens if a 401 was encountered. For advanced usage only in combination with web request authentication.
     
     - parameters:
        - completion: Completion handler with any error that occurred (Optional)
     */
    func refreshTokens(completion: FrolloSDKCompletionHandler?)
    
    /**
     Resume authentication flow (optional)
     
     Resumes the authentication flow, for example in the OAuth2 process
     
     - parameters:
        - url: Deep link passed to the app
     
     - returns: Boolean indicating if the URL was successfully handled or not
     */
    func resumeAuthentication(url: URL) -> Bool
    
    // MARK: - Logout and Reset
    
    /**
     Logout the user if possible and then reset and clear local caches
     */
    func logout()
    
    /**
     Resets any token cache etc and logout the user locally
     */
    func reset()
    
}
