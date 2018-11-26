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
                                      deviceName: String.randomString(range: 1...20),
                                      deviceType: "iPhone Xs",
                                      email: String.randomString(range: 1...10) + "@frollo.us",
                                      firstName: String.randomString(range: 1...20),
                                      password: String.randomString(range: 1...20),
                                      lastName: String.randomString(range: 1...20),
                                      mobileNumber: "0412345678")
    }
    
}
