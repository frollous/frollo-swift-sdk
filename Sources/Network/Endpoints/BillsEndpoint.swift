//
//  BillsEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum BillsEndpoint: Endpoint {
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case bill(billID: Int64)
    case bills
    
    private func urlPath() -> String {
        switch self {
            case .bill(let billID):
                return "bills/" + String(billID)
            case .bills:
                return "bills"
        }
    }

}
