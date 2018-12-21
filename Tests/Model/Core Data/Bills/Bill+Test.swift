//
//  Bill+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Bill: TestableCoreData {
    
    @objc func populateTestData() {
        billID = Int64.random(in: 1...100000)
        accountID = Int64.random(in: 1...100000)
        averageAmount = 400.13
        billType = BillType.allCases.randomElement()!
        details = String.randomString(range: 5...50)
        dueAmount = 43.12
        frequency = Frequency.allCases.randomElement()!
        lastAmount = 61.90
        lastPaymentDateString = "2018-12-13"
        merchantID = Int64.random(in: 1...100000)
        name = String.randomString(range: 5...20)
        nextPaymentDateString = "2019-02-13"
        notes = String.randomString(range: 20...200)
        paymentStatus = PaymentStatus.allCases.randomElement()!
        status = Status.allCases.randomElement()!
    }
    
}
