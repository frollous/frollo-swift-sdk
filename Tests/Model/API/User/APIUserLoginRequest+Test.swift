
//
//  APIUserLoginRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 27/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

@testable import FrolloSDK

extension APIUserLoginRequest {
    
    static func testEmailData() -> APIUserLoginRequest {
        return APIUserLoginRequest(authType: .email,
                                   deviceID: UUID().uuidString,
                                   deviceName: UUID().uuidString,
                                   deviceType: "iPhone X",
                                   email: UUID().uuidString.lowercased() + "@frollo.us",
                                   password: UUID().uuidString,
                                   userID: nil,
                                   userToken: nil)
    }
    
    static func testFacebookData() -> APIUserLoginRequest {
        return APIUserLoginRequest(authType: .facebook,
                                   deviceID: UUID().uuidString,
                                   deviceName: UUID().uuidString,
                                   deviceType: "iPhone X",
                                   email: UUID().uuidString.lowercased() + "@frollo.us",
                                   password: nil,
                                   userID: UUID().uuidString,
                                   userToken: UUID().uuidString)
    }
    
    static func testVoltData() -> APIUserLoginRequest {
        return APIUserLoginRequest(authType: .volt,
                                   deviceID: UUID().uuidString,
                                   deviceName: UUID().uuidString,
                                   deviceType: "iPhone X",
                                   email: nil,
                                   password: nil,
                                   userID: UUID().uuidString,
                                   userToken: UUID().uuidString)
    }
    
    static func testInvalidData() -> APIUserLoginRequest {
        return APIUserLoginRequest(authType: .facebook,
                                   deviceID: UUID().uuidString,
                                   deviceName: UUID().uuidString,
                                   deviceType: "iPhone X",
                                   email: nil,
                                   password: nil,
                                   userID: UUID().uuidString,
                                   userToken: nil)
    }
    
    
}
