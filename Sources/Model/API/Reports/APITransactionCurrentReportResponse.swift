//
// Copyright © 2019 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public struct APITransactionCurrentReportResponse: Codable {
    
    public struct Report: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case averageValue = "average_value"
            case budgetValue = "budget_value"
            case day
            case previousPeriodValue = "previous_period_value"
            case spendValue = "spend_value"
            
        }
        
        public let averageValue: String?
        public let budgetValue: String?
        public let day: Int64
        public let previousPeriodValue: String?
        public let spendValue: String?
        
    }
    
    public struct GroupReport: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case averageValue = "average_value"
            case budgetValue = "budget_value"
            case days
            case id
            case name
            case previousPeriodValue = "previous_period_value"
            case spendValue = "spend_value"
            
        }
        
        public let averageValue: String?
        public let budgetValue: String?
        public let days: [Report]
        public let id: Int64
        public let name: String
        public let previousPeriodValue: String?
        public let spendValue: String?
        
    }
    
    public let groups: [GroupReport]
    public let days: [Report]
    
}
