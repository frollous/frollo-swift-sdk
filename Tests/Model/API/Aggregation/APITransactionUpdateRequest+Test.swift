//
//  APITransactionUpdateRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 9/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APITransactionUpdateRequest {
    
    static func testCompleteData() -> APITransactionUpdateRequest {
        return APITransactionUpdateRequest(budgetCategory: .living,
                                           categoryID: Int64(arc4random()),
                                           included: true,
                                           memo: UUID().uuidString,
                                           userDescription: UUID().uuidString,
                                           includeApplyAll: nil,
                                           recategoriseAll: nil)
    }
    
}
