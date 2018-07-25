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
    
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    internal func authenticate(_ authToken: String, completion: FrolloSDKCompletionHandler) {
        completion(nil)
    }
    
    internal func fetchUser(completion: FrolloSDKCompletionHandler) {
        network.fetchUser { (data, error) in
            if let responseError = error {
                
            }
        }
    }
    
}
