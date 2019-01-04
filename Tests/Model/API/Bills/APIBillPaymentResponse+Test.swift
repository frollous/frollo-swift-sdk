//
//  APIBillPaymentResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIBillPaymentResponse {
    
    static func testCompleteData() -> APIBillPaymentResponse {
        return APIBillPaymentResponse(id: Int64.random(in: 1...1000000000),
                                      amount: "70.05",
                                      billID: Int64.random(in: 1...100000000),
                                      date: "2019-01-13",
                                      frequency: Bill.Frequency.allCases.randomElement()!,
                                      merchantID: Int64.random(in: 1...1000000),
                                      name: String.randomString(range: 5...30),
                                      paymentStatus: Bill.PaymentStatus.allCases.randomElement()!)
    }
    
}
