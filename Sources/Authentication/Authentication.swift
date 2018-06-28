//
//  Authentication.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public struct FrolloSDKAuthenticationNotification {
    public static let authenticationStatusChanged = "FrolloSDKAuthenticationNotification.authenticationStatusChanged"
}

class Authentication {
    
    internal func authenticate(_ authToken: String, completion: FrolloSDKCompletionHandler) {
        completion(nil)
    }
    
}
