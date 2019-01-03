//
//  APIBillCreateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 3/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APIBillCreateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case frequency
        case name
        case nextPaymentDate = "next_payment_date"
        case notes
        case transactionID = "transaction_id"
    }
    
    let frequency: Bill.Frequency
    let name: String?
    let nextPaymentDate: String
    let notes: String?
    let transactionID: Int64
    
}