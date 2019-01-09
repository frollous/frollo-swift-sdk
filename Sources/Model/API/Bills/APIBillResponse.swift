//
//  APIBillsResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIBillResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case averageAmount = "average_amount"
        case billType = "bill_type"
        case category
        case description
        case dueAmount = "due_amount"
        case endDate = "end_date"
        case id
        case frequency
        case lastAmount = "last_amount"
        case lastPaymentDate = "last_payment_date"
        case merchant
        case name
        case nextPaymentDate = "next_payment_date"
        case note
        case paymentStatus = "payment_status"
        case status
    }
    
    struct Category: Codable {
        let id: Int64
        let name: String
    }
    
    struct Merchant: Codable {
        let id: Int64
        let name: String
    }
    
    var id: Int64
    let accountID: Int64?
    let averageAmount: String
    let billType: Bill.BillType
    let category: Category?
    let description: String
    let dueAmount: String
    let endDate: String?
    let frequency: Bill.Frequency
    let lastAmount: String?
    let lastPaymentDate: String?
    let merchant: Merchant?
    let name: String
    let nextPaymentDate: String
    let note: String?
    let paymentStatus: Bill.PaymentStatus
    let status: Bill.Status
    
}
