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

import Foundation
@testable import FrolloSDK

class MockAuthentication: AuthenticationDataSource, AuthenticationDelegate {
    
    class PrivateToken: AccessToken {
        
        let expiryDate: Date? = Date().addingTimeInterval(100000)
        var token: String = UUID().uuidString
        
        func refreshToken() {
            token = UUID().uuidString
        }
        
    }
    
    var accessToken: AccessToken? {
        return privateToken
    }
    var privateToken: PrivateToken? = PrivateToken()
    
    var canSuccessfullyRefresh: Bool = true
    
    init(token: String = UUID().uuidString, valid: Bool = true) {
        if valid {
            privateToken?.token = token
        } else {
            privateToken = nil
        }
    }
    
    func accessTokenExpired(completion: @escaping (Bool) -> Void) {
        (accessToken as? PrivateToken)?.refreshToken()
        
        completion(canSuccessfullyRefresh)
    }
    
    func accessTokenInvalid() {
        privateToken = nil
    }
    
}

class MockAuthenticationCompletion: MockAuthentication {
    
    let expiredCompletion: (() -> Void)?
    let invalidCompletion: (() -> Void)?
    
    init(expiredCompletion: (() -> Void)?, invalidCompletion: (() -> Void)?) {
        self.expiredCompletion = expiredCompletion
        self.invalidCompletion = invalidCompletion
    }
    
    override func accessTokenExpired(completion: @escaping (Bool) -> Void) {
        super.accessTokenExpired(completion: completion)
        
        expiredCompletion?()
    }
    
    override func accessTokenInvalid() {
        super.accessTokenInvalid()
        
        invalidCompletion?()
    }
    
}
