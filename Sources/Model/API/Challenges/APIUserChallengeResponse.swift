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

struct APIUserChallengeResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case challengeID = "challenge_id"
        case currency
        case currentSpendAmount = "current_spend_amount"
        case endDate = "end_date"
        case id = "user_challenge_id"
        case previousAmount = "previous_amount"
        case startDate = "start_date"
        case status
        case targetAmount = "target_amount"
    }
    
    var id: Int64
    let challengeID: Int64
    let currency: String
    let currentSpendAmount: Int64
    let endDate: String
    let previousAmount: Int64
    let startDate: String
    let status: UserChallenge.Status
    let targetAmount: Int64
    
}
