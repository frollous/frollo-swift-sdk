//
//  APIAccountUpdateRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIAccountUpdateRequest {
    
    static func testUpdateDataValid() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(accountType: Account.AccountSubType.allCases.randomElement(),
                                       favourite: Bool.random(),
                                       hidden: false,
                                       included: false,
                                       nickName: String.randomString(range: 2...50))
    }
    
    static func testUpdateDataInvalid() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(accountType: .bankAccount,
                                       favourite: false,
                                       hidden: true,
                                       included: true,
                                       nickName: "My Invalid Account")
    }
    
}
