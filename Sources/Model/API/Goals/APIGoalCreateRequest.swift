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

struct APIGoalCreateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case description
        case endDate = "end_date"
        case frequency
        case imageURL = "image_url"
        case metadata
        case name
        case periodAmount = "period_amount"
        case startAmount = "start_amount"
        case startDate = "start_date"
        case target
        case targetAmount = "target_amount"
        case trackingType = "tracking_type"
    }
    
    let accountID: Int64
    let description: String?
    let endDate: String?
    let frequency: Goal.Frequency
    let imageURL: String?
    let metadata: AnyCodable?
    let name: String
    let periodAmount: String?
    let startAmount: String?
    let startDate: String?
    let target: Goal.Target
    let targetAmount: String?
    let trackingType: Goal.TrackingType
    
    internal func valid() -> Bool {
        switch target {
            case .amount:
                return targetAmount != nil && periodAmount != nil
            case .date:
                return endDate != nil && targetAmount != nil
            case .openEnded:
                return periodAmount != nil && endDate != nil
        }
    }
    
}
