//
//  User+Demo.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

extension User: TestableCoreData {
    
    func populateTestData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date = dateFormatter.date(from: "1990-01")
        
        userID = Int64(arc4random())
        firstName = UUID().uuidString
        lastName = UUID().uuidString
        email = firstName!.lowercased() + "@frollo.us"
        emailVerified = true
        status = .active
        primaryCurrency = "AUD"
        gender = .male
        dateOfBirth = date
        postcode = "2060"
        householdType = .single
        householdSize = 1
        occupation = .communityAndPersonalServiceWorkers
        industry = .electricityGasWaterAndWasteServices
        facebookID = String(arc4random())
        validPassword = true
    }
    
}
