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

struct APIUserGoalResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case baseEndDate = "base_end_date"
        case challengeEndDate = "challenge_end_date"
        case currency
        case currentSavedAmount = "current_saved_amount"
        case currentTargetAmount = "current_target_amount"
        case estimatedEndDate = "estimated_end_date"
        case goalID = "goal_id"
        case id = "user_goal_id"
        case interestRate = "interest_rate"
        case monthlySavingAmount = "monthly_saving_amount"
        case startAmount = "start_amount"
        case startDate = "start_date"
        case status
        case targetAmount = "target_amount"
    }
    
    var id: Int64
    let baseEndDate: String
    let challengeEndDate: String
    let currency: String
    let currentSavedAmount: String
    let currentTargetAmount: String
    let estimatedEndDate: String
    let goalID: Int64
    let interestRate: String
    let monthlySavingAmount: String
    let startAmount: String
    let startDate: String
    let status: UserGoal.Status
    let targetAmount: String
    
}
