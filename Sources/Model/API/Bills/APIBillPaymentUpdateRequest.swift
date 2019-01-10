//
//  APIBillPaymentUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

struct APIBillPaymentUpdateRequest: Codable {
    
    let status: Bill.PaymentStatus?
    
}
