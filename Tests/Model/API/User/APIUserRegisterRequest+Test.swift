//
//  APIUserRegisterRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIUserRegisterRequest {
    
    static func testData() -> APIUserRegisterRequest {
        return APIUserRegisterRequest(deviceID: UUID().uuidString,
                                      deviceName: UUID().uuidString,
                                      deviceType: "iPhone Xs",
                                      email: UUID().uuidString.lowercased() + "@frollo.us",
                                      firstName: UUID().uuidString,
                                      password: UUID().uuidString,
                                      lastName: UUID().uuidString)
    }
    
}
