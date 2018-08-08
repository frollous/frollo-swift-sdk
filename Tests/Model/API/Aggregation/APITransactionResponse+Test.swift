//
//  APITransactionResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APITransactionResponse {
    
    static func testCompleteData() -> APITransactionResponse {
        let amount = Amount(amount: "186.99",
                            currency: "AUD")
        let description = Description(original: UUID().uuidString,
                                      simple: UUID().uuidString,
                                      user: UUID().uuidString)
        
        return APITransactionResponse(id: Int64(arc4random()),
                                      accountID: Int64(arc4random()),
                                      amount: amount,
                                      baseType: .debit,
                                      billID: Int64(arc4random()),
                                      billPaymentID: Int64(arc4random()),
                                      budgetCategory: .living,
                                      categoryID: Int64(arc4random()),
                                      description: description,
                                      included: true,
                                      memo: UUID().uuidString,
                                      merchantID: Int64(arc4random()),
                                      merchantName: UUID().uuidString,
                                      postDate: Date(timeIntervalSinceNow: -1000),
                                      status: .posted,
                                      transactionDate: Date(timeIntervalSinceNow: -1000))
    }
    
    static func testIncompleteData() -> APITransactionResponse {
        let amount = Amount(amount: "186.99",
                            currency: "AUD")
        let description = Description(original: UUID().uuidString,
                                      simple: nil,
                                      user: nil)
        
        return APITransactionResponse(id: Int64(arc4random()),
                                      accountID: Int64(arc4random()),
                                      amount: amount,
                                      baseType: .debit,
                                      billID: nil,
                                      billPaymentID: nil,
                                      budgetCategory: .living,
                                      categoryID: Int64(arc4random()),
                                      description: description,
                                      included: true,
                                      memo: nil,
                                      merchantID: Int64(arc4random()),
                                      merchantName: nil,
                                      postDate: nil,
                                      status: .posted,
                                      transactionDate: Date(timeIntervalSinceNow: -1000))
    }
    
}
