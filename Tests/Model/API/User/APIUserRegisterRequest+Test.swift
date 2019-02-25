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
        return APIUserRegisterRequest(email: String.randomString(range: 1...10) + "@frollo.us",
                                      firstName: String.randomString(range: 1...20),
                                      password: String.randomString(range: 1...20),
                                      address: Address(postcode: "2060"),
                                      dateOfBirth: Date(timeIntervalSince1970: 631152000),
                                      lastName: String.randomString(range: 1...20),
                                      mobileNumber: "0412345678")
    }
    
}
