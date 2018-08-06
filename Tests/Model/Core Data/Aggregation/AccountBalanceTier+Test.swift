//
//  AccountBalanceTier+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension AccountBalanceTier: TestableCoreData {
    
    func populateTestData() {
        name = UUID().uuidString
        minimum = Decimal(arc4random()) as NSDecimalNumber?
        maximum = Decimal(arc4random()) as NSDecimalNumber?
    }
    
}
