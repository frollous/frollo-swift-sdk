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
        return APIAccountUpdateRequest(favourite: true,
                                       hidden: false,
                                       included: false,
                                       nickName: "My Account Name")
    }
    
    static func testUpdateDataInvalid() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(favourite: false,
                                       hidden: true,
                                       included: true,
                                       nickName: "My Invalid Account")
    }
    
}
