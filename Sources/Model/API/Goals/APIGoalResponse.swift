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
        case community
        case description
        case goalType = "goal_type"
        case id
        case largeLogoURL = "large_logo_url"
        case name
        case smallLogoURL = "small_logo_url"
        case source
        //case user
    }
    
    struct Community: Codable {
        
        enum CodingKeys: String, CodingKey {
            case activeCount = "active_count"
            case averageMonths = "average_months"
            case averageTargetAmount = "average_target_amount"
            case completedCount = "completed_count"
            case startedCount = "started_count"
        }
        
        let activeCount: Int64
        let averageMonths: Int64
        let averageTargetAmount: Int64
        let completedCount: Int64
        let startedCount: Int64
        
    }
    
    var id: Int64
    let community: Community
    let description: String?
    let goalType: Goal.GoalType
    let largeLogoURL: String?
    let name: String
    let smallLogoURL: String?
    let source: Goal.Source
    //let user: APIUserGoalResponse?
    
}
