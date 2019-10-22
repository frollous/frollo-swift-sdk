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

extension APIGoalCreateRequest {
    
    static func testInvalidData() -> APIGoalCreateRequest {
        return APIGoalCreateRequest(accountID: Int64.random(in: 1...Int64.max),
                                    description: String.randomString(range: 1...200),
                                    endDate: "2019-12-31",
                                    frequency: .monthly,
                                    imageURL: "https://example.com/image.png",
                                    metadata: nil,
                                    name: String.randomString(range: 1...20),
                                    periodAmount: "300",
                                    startAmount: "0",
                                    startDate: "2018-10-01",
                                    target: .amount,
                                    targetAmount: nil,
                                    trackingType: Goal.TrackingType.allCases.randomElement()!)
    }
    
    static func testAmountTargetData() -> APIGoalCreateRequest {
        return APIGoalCreateRequest(accountID: Int64.random(in: 1...Int64.max),
                                    description: String.randomString(range: 1...200),
                                    endDate: "2019-12-31",
                                    frequency: .monthly,
                                    imageURL: "https://example.com/image.png",
                                    metadata: ["seen": true],
                                    name: String.randomString(range: 1...20),
                                    periodAmount: nil,
                                    startAmount: "0",
                                    startDate: "2018-10-01",
                                    target: .amount,
                                    targetAmount: "20000",
                                    trackingType: Goal.TrackingType.allCases.randomElement()!)
    }
    
    static func testDateTargetData() -> APIGoalCreateRequest {
        return APIGoalCreateRequest(accountID: Int64.random(in: 1...Int64.max),
                                    description: String.randomString(range: 1...200),
                                    endDate: nil,
                                    frequency: .monthly,
                                    imageURL: "https://example.com/image.png",
                                    metadata: ["seen": true],
                                    name: String.randomString(range: 1...20),
                                    periodAmount: "300",
                                    startAmount: "0",
                                    startDate: "2018-10-01",
                                    target: .date,
                                    targetAmount: "20000",
                                    trackingType: Goal.TrackingType.allCases.randomElement()!)
    }
    
    static func testOpenEndedTargetData() -> APIGoalCreateRequest {
        return APIGoalCreateRequest(accountID: Int64.random(in: 1...Int64.max),
                                    description: String.randomString(range: 1...200),
                                    endDate: "2019-12-31",
                                    frequency: .monthly,
                                    imageURL: "https://example.com/image.png",
                                    metadata: ["seen": true],
                                    name: String.randomString(range: 1...20),
                                    periodAmount: "300",
                                    startAmount: "0",
                                    startDate: "2018-10-01",
                                    target: .openEnded,
                                    targetAmount: nil,
                                    trackingType: Goal.TrackingType.allCases.randomElement()!)
    }
    
}
