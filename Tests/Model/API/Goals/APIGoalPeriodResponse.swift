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

struct APIGoalPeriodResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case currentAmount = "current_amount"
        case endDate = "end_date"
        case goalID = "goal_id"
        case id
        case index
        case requiredAmount = "required_amount"
        case startDate = "start_date"
        case targetAmount = "target_amount"
        case trackingStatus = "tracking_status"
    }
    
    var id: Int64
    let currentAmount: String
    let endDate: String
    let goalID: Int64
    let index: Int64
    let requiredAmount: String
    let startDate: String
    let targetAmount: String
    let trackingStatus: Goal.TrackingStatus
    
}
