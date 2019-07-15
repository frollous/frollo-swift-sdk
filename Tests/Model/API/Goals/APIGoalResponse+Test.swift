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

extension APIGoalResponse {
    
    static func testCompleteData() -> APIGoalResponse {
        return APIGoalResponse(id: Int64.random(in: 1...Int64.max),
                               accountID: Int64.random(in: 1...Int64.max),
                               currentAmount: "4514.73",
                               currency: "AUD",
                               description: String.randomString(range: 5...100),
                               endDate: Date().addingTimeInterval(10000),
                               estimatedEndDate: Date().addingTimeInterval(9000),
                               estimatedTargetAmount: "25000",
                               frequency: Goal.Frequency.allCases.randomElement()!,
                               imageURL: "https://example.com/image.png",
                               name: String.randomString(range: 5...20),
                               periodAmount: "250",
                               periodsCount: Int64.random(in: 1...Int64.max),
                               startAmount: "0",
                               startDate: Date().addingTimeInterval(-1000),
                               status: Goal.Status.allCases.randomElement()!,
                               subType: String.randomString(range: 5...20),
                               target: Goal.Target.allCases.randomElement()!,
                               targetAmount: "26000",
                               trackingStatus: Goal.TrackingStatus.allCases.randomElement()!,
                               trackingType: Goal.TrackingType.allCases.randomElement()!,
                               type: String.randomString(range: 5...20))
    }
    
}
