//
//  APITransactionCategoryResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APITransactionCategoryResponse {
    
    static func testCompleteData() -> APITransactionCategoryResponse {
        return APITransactionCategoryResponse(id: Int64(arc4random()),
                                              categoryType: .expense,
                                              defaultBudgetCategory: .living,
                                              iconURL: "https://example.com/category.png",
                                              name: UUID().uuidString,
                                              placement: Int64(arc4random()),
                                              userDefined: false)
    }
    
}
