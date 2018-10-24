//
//  Merchant+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Merchant: TestableCoreData {
    
    func populateTestData() {
        merchantID = Int64(arc4random())
        merchantType = .retailer
        name = UUID().uuidString
        smallLogoURLString = "https://example.com/merchant.png"
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        merchantID = id
    }
    
}
