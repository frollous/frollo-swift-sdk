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
                                      postDate: "2018-08-05",
                                      status: .posted,
                                      transactionDate: "2018-08-03")
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
                                      postDate: nil,
                                      status: .posted,
                                      transactionDate: "2018-08-03")
    }
    
}
