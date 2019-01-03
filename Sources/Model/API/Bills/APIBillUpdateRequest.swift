//
//  APIBillUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APIBillUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case billType = "bill_type"
        case dueAmount = "due_amount"
        case frequency
        case name
        case nextPaymentDate = "next_payment_date"
        case note
        case status
    }
    
    let billType: Bill.BillType
    let dueAmount: String
    let frequency: Bill.Frequency
    let name: String?
    let nextPaymentDate: String
    let note: String?
    let status: Bill.Status
    
}
