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

extension APIUserGoalResponse {
    
    static func testCompleteData() -> APIUserGoalResponse {
        return APIUserGoalResponse(id: Int64.random(in: 1...Int64.max),
                                   baseEndDate: "2023-03-01",
                                   challengeEndDate: "2022-03-01",
                                   currency: "AUD",
                                   currentSavedAmount: "4537.98",
                                   currentTargetAmount: "1113.86",
                                   estimatedEndDate: "2021-03-01",
                                   goalID: Int64.random(in: 1...Int64.max),
                                   interestRate: "2.8",
                                   monthlySavingAmount: "255",
                                   startAmount: "3000",
                                   startDate: "2018-12-15",
                                   status: UserGoal.Status.allCases.randomElement()!,
                                   targetAmount: "10000")
    }
    
}
