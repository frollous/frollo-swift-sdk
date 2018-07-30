//
//  Keychain+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

extension Keychain {
    
    static func validNetworkKeychain(service: String) -> Keychain {
        let keychain = Keychain(service: service)
        
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970) // Not expired by time
        
        return keychain
    }
    
}
