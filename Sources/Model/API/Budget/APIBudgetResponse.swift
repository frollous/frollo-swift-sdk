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
import SwiftyJSON

struct APIBudgetResponse: Codable, APIUniqueResponse {
    
    enum CodingKeys: String, CodingKey {
        case budgetType = "type"
        case currentAmount = "current_amount"
        case currentPeriod = "current_period"
        case currency
        case estimatedTargetAmount = "estimated_target_amount"
        case frequency
        case id
        case isCurrent = "is_current"
        case metadata
        case periodAmount = "period_amount"
        case periodsCount = "periods_count"
        case startDate = "start_date"
        case status
        case targetAmount = "target_amount"
        case trackingStatus = "tracking_status"
        case typeValue = "type_value"
        case userID = "user_id"
    }
    
    var id: Int64
    let currentAmount: String
    let currentPeriod: APIBudgetPeriodResponse?
    let isCurrent: Bool
    let currency: String
    let estimatedTargetAmount: String?
    let frequency: Budget.Frequency
    let metadata: JSON?
    let periodAmount: String
    let periodsCount: Int64
    let startDate: String
    let status: Budget.Status
    let targetAmount: String
    let trackingStatus: Budget.TrackingStatus
    let budgetType: Budget.BudgetType
    let typeValue: String
    let userID: Int64
    
}
