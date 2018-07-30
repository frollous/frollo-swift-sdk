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
                               address: Address(postcode: "2060"),
                               dateOfBirth: date,
                               facebookID: String(arc4random()),
                               features: [User.FeatureFlag(enabled: true, feature: .aggregation)],
                               gender: .male,
                               householdSize: 1,
                               householdType: .single,
                               industry: .electricityGasWaterAndWasteServices,
                               lastName: UUID().uuidString,
                               occupation: .communityAndPersonalServiceWorkers)
    }
    
}
