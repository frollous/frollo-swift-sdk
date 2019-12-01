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

extension Budget: TestableCoreData {
    
    @objc func populateTestData() {
        budgetID = Int64.random(in: 1...Int64.max)
        accountID = Int64.random(in: 1...Int64.max)
        isCurrent = Bool.random()
        currentAmount = 7514.92
        currency = "AUD"
        startDateString = "2019-12-02"
        estimatedTargetAmount = 20000
        frequency = Frequency.allCases.randomElement()!
        imageURLString = "https://example.com/image.png"
        metadata = ["seen": Bool.random()]
        periodAmount = 300
        startAmount = 0
        periodsCount = Int64.random(in: 1...12)
        status = Status.allCases.randomElement()!
        targetAmount = 20000
        trackingStatus = TrackingStatus.allCases.randomElement()!
        trackingType = TrackingType.allCases.randomElement()!
    }
    
}

