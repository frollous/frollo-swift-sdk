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

extension APIBudgetResponse {
    
    static func testCompleteData() -> APIBudgetResponse {
        
        let period = APIBudgetPeriodResponse.testCompleteData()
                                        
        return APIBudgetResponse(id: Int64.random(in: 1...Int64.max),
                                 currentAmount: "100",
                                 currentPeriod: period,
                                 isCurrent: true,
                                 currency: "4514",
                                 estimatedTargetAmount: "5000",
                                 frequency: Budget.Frequency.allCases.randomElement()!,
                                 metadata: ["seen": true],
                                 periodAmount: "25000",
                                 periodsCount: 10,
                                 startDate: "2019-11-02",
                                 status: Budget.Status.allCases.randomElement()!,
                                 imageURL: "http://www.example.com/image/image_1.png",
                                 trackingStatus: Budget.TrackingStatus.allCases.randomElement()!,
                                 budgetType: Budget.BudgetType.allCases.randomElement()!,
                                 typeValue: "",
                               userID: 11)
    }
    
}
