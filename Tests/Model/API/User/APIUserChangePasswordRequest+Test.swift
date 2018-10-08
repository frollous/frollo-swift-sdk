//
//  APIUserChangePasswordRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIUserChangePasswordRequest {
    
    static func testData() -> APIUserChangePasswordRequest {
        return APIUserChangePasswordRequest(currentPassword: UUID().uuidString,
                                            newPassword: UUID().uuidString)
    }
    
}
