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

enum ChallengesEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    case challenge(challengeID: Int64)
    case challenges
    case userChallenge(userChallengeID: Int64)
    case userChallenges
    
    private func urlPath() -> String {
        switch self {
            case .challenge(let challengeID):
                return "challenges/" + String(challengeID)
            case .challenges:
                return "challenges"
            case .userChallenge(let userChallengeID):
                return "challenges/user/" + String(userChallengeID)
            case .userChallenges:
                return "challenges/user"
        }
    }
    
}
