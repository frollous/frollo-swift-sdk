//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CoreData
import XCTest
@testable import FrolloSDK

extension User: TestableCoreData {
    
    func populateTestData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date = dateFormatter.date(from: "1990-01")
        
        userID = Int64.random(in: 1...Int64.max)
        firstName = UUID().uuidString
        lastName = UUID().uuidString
        email = firstName!.lowercased() + "@frollo.us"
        emailVerified = true
        status = .active
        primaryCurrency = "AUD"
        gender = .male
        dateOfBirth = date
        currentAddress = getTestAddress()
        mailingAddress = getTestAddress()
        mobileNumber = "0412345678"
        householdType = .single
        householdSize = 1
        occupation = .communityAndPersonalServiceWorkers
        industry = .electricityGasWaterAndWasteServices
        facebookID = String(arc4random())
        attributionAdGroup = String.randomString(range: 1...10)
        attributionCampaign = String.randomString(range: 1...10)
        attributionCreative = String.randomString(range: 1...10)
        attributionNetwork = String.randomString(range: 1...10)
        validPassword = true
        foreignTax = false
        tin = "12345"
        tfn = "12345678"
        taxResidency = "AU"
    }
    
    func getTestAddress() -> Address{
        return Address(buildingName: "100 Mount", unitNumber: "Unit 3", streetNumber: "100", streetName: "Mount", streetType: "street", suburb: "North Sydney", town: "Sydney", region: "Greater Sydney", state: "NSW", country: "AU", postcode: "2060", longForm: "Frollo, Level 33, 100 Mount St, North Sydney, NSW, 2060, Australia")
    }
    
}

