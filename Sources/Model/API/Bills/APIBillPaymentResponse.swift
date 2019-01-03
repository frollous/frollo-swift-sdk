//
//  APIBillPaymentResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 3/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APIBillPaymentResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case billID = "bill_id"
        case date
        case frequency
        case id
        case merchantID = "merchant_id"
        case name
        case paymentStatus = "payment_status"
    }
    
    var id: Int64
    let amount: String
    let billID: Int64
    let date: String
    let frequency: Bill.Frequency
    let merchantID: Int64
    let name: String
    let paymentStatus: Bill.PaymentStatus
    
}
