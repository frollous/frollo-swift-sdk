//
// Copyright © 2018 Frollo. All rights reserved.
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

/**
 Budget Category
 
 Indicates a budget type
 */
public enum BudgetCategory: String, Codable, CaseIterable {
    
    /// Income budget
    case income
    
    /// Lifestyle budget
    case lifestyle
    
    /// Living budget
    case living
    
    /// One offs budget
    case oneOff = "one_off"
    
    /// Savings budget
    case savings = "goals"
    
    init?(id: Int64) {
        switch id {
            case 0:
                self = .income
            case 1:
                self = .living
            case 2:
                self = .lifestyle
            case 3:
                self = .savings
            case 4:
                self = .oneOff
            default:
                return nil
        }
    }
    
}
