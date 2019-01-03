//
//  APIBillCreateRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 3/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIBillCreateRequest {
    
    static func testCompleteData() -> APIBillCreateRequest {
        return APIBillCreateRequest(frequency: Bill.Frequency.allCases.randomElement()!,
                                    name: String.randomString(range: 5...20),
                                    nextPaymentDate: "2020-03-01",
                                    notes: String.randomString(range: 10...100),
                                    transactionID: Int64.random(in: 1...10000000))
    }
    
}
