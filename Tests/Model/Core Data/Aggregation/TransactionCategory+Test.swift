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

extension TransactionCategory: TestableCoreData {
    
    func populateTestData() {
        transactionCategoryID = Int64(arc4random())
        categoryType = .expense
        defaultBudgetCategory = .living
        iconURLString = "https://example.com/category.png"
        name = UUID().uuidString
        userDefined = false
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        transactionCategoryID = id
    }
    
}
