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
                               primaryCurrency: "AUD",
                               status: .active,
                               userID: Int64(arc4random()),
                               validPassword: true,
                               address: User.UserAddress(id: 0, longForm: ""),
                               mailingAddress: User.UserAddress(id: 1, longForm: ""),
                               previousAddress: User.UserAddress(id: 2, longForm: ""),
                               attribution: Attribution(adGroup: String.randomString(range: 1...10), campaign: String.randomString(range: 1...10), creative: String.randomString(range: 1...10), network: String.randomString(range: 1...10)),
                               dateOfBirth: date,
                               facebookID: String(arc4random()),
                               features: [User.FeatureFlag(enabled: true, feature: "aggregation")],
                               firstName: name,
                               gender: .male,
                               householdSize: 1,
                               householdType: .single,
                               industry: .electricityGasWaterAndWasteServices,
                               lastName: UUID().uuidString,
                               mobileNumber: "0412345678",
                               occupation: .communityAndPersonalServiceWorkers,
                               registerSteps: [User.RegisterStep(key: "survey", index: 0, required: true, completed: false), User.RegisterStep(key: "kyc", index: 1, required: true, completed: false)],
                               tfn: "12345678",
                               taxResidency: "AU",
                               foreignTax: false,
                               tin: "12345",
                               externalID: "123456")
    }
    
}
