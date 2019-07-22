//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@testable import FrolloSDK

extension Goal: TestableCoreData {
    
    @objc func populateTestData() {
        goalID = Int64.random(in: 1...Int64.max)
        accountID = Int64.random(in: 1...Int64.max)
        currentAmount = 7514.92
        currency = "AUD"
        details = String.randomString(range: 5...100)
        endDateString = "2019-11-02"
        estimatedEndDateString = "2019-12-02"
        estimatedTargetAmount = 20000
        frequency = Frequency.allCases.randomElement()!
        imageURLString = "https://example.com/image.png"
        name = String.randomString(range: 5...20)
        periodAmount = 300
        periodCount = 52
        startAmount = 0
        startDateString = "2019-01-02"
        status = Status.allCases.randomElement()!
        subType = String.randomString(range: 5...20)
        target = Target.allCases.randomElement()!
        targetAmount = 20000
        trackingStatus = TrackingStatus.allCases.randomElement()!
        trackingType = TrackingType.allCases.randomElement()!
        type = String.randomString(range: 5...20)
    }
    
}
