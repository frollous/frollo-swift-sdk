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

public protocol AuthenticationDelegate: AnyObject {
    
    func authenticationReset()
    
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
    
    var delegate: AuthenticationDelegate? { get set }
    
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
     Resets any token cache etc and logout the user
     */
    func reset()
    
}
