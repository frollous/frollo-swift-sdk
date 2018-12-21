//
//  APIBillResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIBillResponse {
    
    static func testCompleteData() -> APIBillResponse {
        let category = Category(id: Int64.random(in: 1...100000),
                                name: String.randomString(range: 5...20))
        
        let merchant = Merchant(id: Int64.random(in: 1...100000),
                                name: String.randomString(range: 5...20))
        
        return APIBillResponse(id: Int64.random(in: 1...100000),
                               accountID: Int64.random(in: 1...100000),
                               averageAmount: "99.89",
                               billType: Bill.BillType.allCases.randomElement()!,
                               category: category,
                               description: String.randomString(range: 5...50),
                               dueAmount: "79.65",
                               frequency: Bill.Frequency.allCases.randomElement()!,
                               lastAmount: "101.23",
                               lastPaymentDate: "2018-12-01",
                               merchant: merchant,
                               name: String.randomString(range: 5...50),
                               nextPaymentDate: "2019-01-01",
                               note: String.randomString(range: 10...200),
                               paymentStatus: Bill.PaymentStatus.allCases.randomElement()!,
                               status: Bill.Status.allCases.randomElement()!)
    }
    
}
