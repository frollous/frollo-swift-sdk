//
//  BillsEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum BillsEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case count
        case fromDate = "from_date"
        case skip
        case toDate = "to_date"
    }
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case bill(billID: Int64)
    case bills
    case payment(billPaymentID: Int64)
    case payments
    
    private func urlPath() -> String {
        switch self {
            case .bill(let billID):
                return "bills/" + String(billID)
            case .bills:
                return "bills"
            case .payment(let billPaymentID):
                return "bills/payments/" + String(billPaymentID)
            case .payments:
                return "bills/payments"
        }
    }

}
