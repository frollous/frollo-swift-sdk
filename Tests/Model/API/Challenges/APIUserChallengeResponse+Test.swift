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

extension APIUserChallengeResponse {
    
    static func testCompleteData() -> APIUserChallengeResponse {
        return APIUserChallengeResponse(id: Int64.random(in: 1...Int64.max),
                                 challengeID: Int64.random(in: 1...Int64.max),
                                 currency: "AUD",
                                 currentSpendAmount: 144,
                                 endDate: "2019-03-08",
                                 previousAmount: 350,
                                 startDate: "2019-03-01",
                                 status: UserChallenge.Status.allCases.randomElement()!,
                                 targetAmount: 200)
    }
    
}
