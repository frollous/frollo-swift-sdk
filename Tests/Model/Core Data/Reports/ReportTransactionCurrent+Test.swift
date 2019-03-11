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

import CoreData
import Foundation
@testable import FrolloSDK

extension ReportTransactionCurrent: TestableCoreData {
    
    internal func populateTestData() {
        amount = NSDecimalNumber(string: "34.67")
        average = NSDecimalNumber(string: "29.50")
        budget = NSDecimalNumber(string: "30.00")
        filterBudgetCategory = Bool.random() ? BudgetCategory.allCases.randomElement() : nil
        day = Int64.random(in: 1...31)
        grouping = ReportGrouping.allCases.randomElement()!
        name = String.randomString(range: 3...30)
        linkedID = Bool.random() ? Int64.random(in: 1...1000000) : -1
        previous = NSDecimalNumber(string: "31.33")
    }
    
}
