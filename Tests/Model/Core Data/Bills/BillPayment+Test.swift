//
//  BillPayment+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension BillPayment: TestableCoreData {
    
    @objc func populateTestData() {
        billPaymentID = Int64.random(in: 1...100000000)
        billID = Int64.random(in: 1...1000000000)
        name = String.randomString(range: 5...30)
        merchantID = Int64.random(in: 1...1000000)
        dateString = "2021-01-01"
        paymentStatus = Bill.PaymentStatus.allCases.randomElement()!
        frequency = Bill.Frequency.allCases.randomElement()!
        amount = NSDecimalNumber(string: "61.11")
    }
    
}
