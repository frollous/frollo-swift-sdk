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
        case fromDate = "from_date"
        case toDate = "to_date"
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case bill(billID: Int64)
    case bills
    case billPayment(billPaymentID: Int64)
    case billPayments
    
    private func urlPath() -> String {
        switch self {
            case .bill(let billID):
                return "bills/" + String(billID)
            case .bills:
                return "bills"
            case .billPayment(let billPaymentID):
                return "bills/payments/" + String(billPaymentID)
            case .billPayments:
                return "bills/payments"
        }
    }
    
}
