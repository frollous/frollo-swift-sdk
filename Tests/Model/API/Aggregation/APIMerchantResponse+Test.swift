//
//  APIMerchantResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIMerchantResponse {
    
    static func testCompleteData() -> APIMerchantResponse {
        return APIMerchantResponse(id: Int64(arc4random()),
                                   merchantType: .retailer,
                                   name: UUID().uuidString,
                                   smallLogoURL: "https://example.com/merchant.png")
    }
    
}
