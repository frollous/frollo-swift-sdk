//
//  APIBillUpdateRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 3/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIBillUpdateRequest {
    
    static func testCompleteData() -> APIBillUpdateRequest {
        return APIBillUpdateRequest(billType: Bill.BillType.allCases.randomElement()!,
                                    dueAmount: "30.53",
                                    frequency: Bill.Frequency.allCases.randomElement()!,
                                    name: String.randomString(range: 5...30),
                                    nextPaymentDate: "2020-01-20",
                                    note: String.randomString(range: 5...200),
                                    status: Bill.Status.allCases.randomElement()!)
    }
    
}
