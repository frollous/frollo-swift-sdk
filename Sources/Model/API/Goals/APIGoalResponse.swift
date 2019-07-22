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

struct APIGoalResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case currentAmount = "current_amount"
        // case currentPeriod = "current_period"
        case currency
        case description
        case endDate = "end_date"
        case estimatedEndDate = "estimated_end_date"
        case estimatedTargetAmount = "estimated_target_amount"
        case frequency
        case id
        case imageURL = "image_url"
        case name
        case periodAmount = "period_amount"
        case periodsCount = "periods_count"
        case startAmount = "start_amount"
        case startDate = "start_date"
        case status
        case subType = "sub_type"
        case target
        case targetAmount = "target_amount"
        case trackingStatus = "tracking_status"
        case trackingType = "tracking_type"
        case type
    }
    
    var id: Int64
    let accountID: Int64?
    let currentAmount: String
    // let currentPeriod: GoalPeriod
    let currency: String
    let description: String?
    let endDate: String
    let estimatedEndDate: String?
    let estimatedTargetAmount: String?
    let frequency: Goal.Frequency
    let imageURL: String
    let name: String
    let periodAmount: String
    let periodsCount: Int64
    let startAmount: String
    let startDate: String
    let status: Goal.Status
    let subType: String?
    let target: Goal.Target
    let targetAmount: String
    let trackingStatus: Goal.TrackingStatus
    let trackingType: Goal.TrackingType
    let type: String?
    
}
