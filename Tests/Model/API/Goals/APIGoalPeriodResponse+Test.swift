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

extension APIGoalPeriodResponse {
    
    static func testCompleteData() -> APIGoalPeriodResponse {
        return APIGoalPeriodResponse(id: Int64.random(in: 1...Int64.max),
                                     currentAmount: "172.01",
                                     endDate: "2020-03-31",
                                     goalID: Int64.random(in: 1...Int64.max),
                                     requiredAmount: "330",
                                     startDate: "2018-04-01",
                                     targetAmount: "275",
                                     trackingStatus: Goal.TrackingStatus.allCases.randomElement()!)
    }
    
}
