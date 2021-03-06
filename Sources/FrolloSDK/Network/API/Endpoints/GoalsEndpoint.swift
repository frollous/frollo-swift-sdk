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

enum GoalsEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case status
        case trackingStatus = "tracking_status"
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case goal(goalID: Int64)
    case goals
    case period(goalID: Int64, goalPeriodID: Int64)
    case periods(goalID: Int64)
    
    private func urlPath() -> String {
        switch self {
            case .goal(let goalID):
                return "goals/" + String(goalID)
            case .goals:
                return "goals"
            case .period(let goalID, let goalPeriodID):
                return "goals/" + String(goalID) + "/periods/" + String(goalPeriodID)
            case .periods(let goalID):
                return "goals/" + String(goalID) + "/periods"
        }
    }
    
}
