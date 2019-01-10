//
//  APIBillPaymentUpdateRequest+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIBillPaymentUpdateRequest {
    
    static func testCompleteData() -> APIBillPaymentUpdateRequest {
        return APIBillPaymentUpdateRequest(status: Bill.PaymentStatus.allCases.randomElement()!)
    }
    
}
