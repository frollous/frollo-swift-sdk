//
//  APIUserResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import XCTest
@testable import FrolloSDK

extension APIUserResponse {
    
    static func testData() -> APIUserResponse {
        let name = UUID().uuidString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date = dateFormatter.date(from: "1990-01")
        
        return APIUserResponse(email: name + "@frollo.us",
                               emailVerified: true,
                               firstName: name,
                               primaryCurrency: "AUD",
                               status: .active,
                               userID: Int64(arc4random()),
                               validPassword: true,
                               address: Address(line1: "41 McLaren Street", line2: "Frollo Level 1", postcode: "2060", suburb: "North Sydney"),
                               dateOfBirth: date,
                               facebookID: String(arc4random()),
                               features: [User.FeatureFlag(enabled: true, feature: "aggregation")],
                               gender: .male,
                               householdSize: 1,
                               householdType: .single,
                               industry: .electricityGasWaterAndWasteServices,
                               lastName: UUID().uuidString,
                               occupation: .communityAndPersonalServiceWorkers,
                               previousAddress: Address(line1: "Bay 9 Middlemiss St", line2: "Frollo Unit 13", postcode: "2060", suburb: "Lavender Bay"))
    }
    
}
