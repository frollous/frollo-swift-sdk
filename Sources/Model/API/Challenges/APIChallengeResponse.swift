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

struct APIChallengeResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case challengeType = "challenge_type"
        case community
        case description
        case frequency
        case id
        case largeLogoURL = "large_logo_url"
        case name
        case smallLogoURL = "small_logo_url"
        case source
        case steps
    }
    
    struct Community: Codable {
        
        enum CodingKeys: String, CodingKey {
            case activeCount = "active_count"
            case averageSavingAmount = "average_saving_amount"
            case completedCount = "completed_count"
            case startedCount = "started_count"
        }
        
        let activeCount: Int64
        let averageSavingAmount: Int64
        let completedCount: Int64
        let startedCount: Int64
        
    }
    
    var id: Int64
    let challengeType: Challenge.ChallengeType
    let community: Community
    let description: String?
    let frequency: Challenge.Frequency
    let largeLogoURL: String?
    let name: String
    let smallLogoURL: String?
    let steps: [String]
    let source: Challenge.Source
    
}
