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
@testable import FrolloSDK

extension Transaction: TestableCoreData {
    
    func populateTestData() {
        transactionID = Int64.random(in: 1...Int64.max)
        accountID = Int64.random(in: 1...Int64.max)
        merchantID = Int64.random(in: 1...Int64.max)
        transactionCategoryID = Int64.random(in: 1...Int64.max)
        memo = UUID().uuidString
        originalDescription = UUID().uuidString
        simpleDescription = UUID().uuidString
        userDescription = UUID().uuidString
        amount = Decimal(186.99) as NSDecimalNumber
        currency = "AUD"
        included = false
        baseType = .debit
        budgetCategory = .lifestyle
        status = .pending
        postDate = Date(timeIntervalSinceNow: -1000)
        transactionDate = Date(timeIntervalSinceNow: -1000)
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        transactionID = id
    }
    
}
