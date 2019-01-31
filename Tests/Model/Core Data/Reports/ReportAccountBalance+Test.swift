//
//  ReportAccountBalance+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension ReportAccountBalance: TestableCoreData {
    
    internal func populateTestData() {
        accountID = Int64.random(in: 1...1000000000)
        currency = "AUD"
        period = Period.allCases.randomElement()!
        value = NSDecimalNumber(string: "2086.91")
        
        switch period {
            case .day:
                dateString = "2018-03-01"
            case .month:
                dateString = "2018-03"
            case .week:
                dateString = "2018-26"
        }
    }

}
