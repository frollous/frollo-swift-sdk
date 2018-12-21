//
//  APIBillsResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIBillsResponse {
    
    static func testCompleteData() -> APIBillsResponse {
        let period = BudgetPeriod(amountPaid: "100.5",
                                  amountRemaining: "49.5")
        
        var bills = [APIBillResponse]()
        for _ in 0...20 {
            bills.append(APIBillResponse.testCompleteData())
        }
        
        return APIBillsResponse(bills: bills,
                                budgetPeriod: period)
    }
    
}
