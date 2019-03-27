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

import CoreData
import Foundation

@testable import FrolloSDK

extension Goal: TestableCoreData {
    
    @objc func populateTestData() {
        goalID = Int64.random(in: 1...Int64.max)
        activeCount = Int64.random(in: 1...Int64.max)
        averageMonths = Int64.random(in: 1...Int64.max)
        averageTargetAmount = 10200
        completedCount = Int64.random(in: 1...Int64.max)
        details = String.randomString(range: 10...200)
        goalType = GoalType.allCases.randomElement()!
        largeLogoURLString = "https://example.com/large.png"
        name = String.randomString(range: 5...50)
        smallLogoURLString = "https://example.com/small.png"
        source = Source.allCases.randomElement()!
        startedCount = Int64.random(in: 1...Int64.max)
    }
    
}
