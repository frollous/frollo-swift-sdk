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

extension APITransactionResponse {
    
    static func testCompleteData() -> APITransactionResponse {
        let amount = Amount(amount: "186.99",
                            currency: "AUD")
        let description = Description(original: UUID().uuidString,
                                      simple: UUID().uuidString,
                                      user: UUID().uuidString)
        
        return APITransactionResponse(id: Int64(arc4random()),
                                      accountID: Int64(arc4random()),
                                      amount: amount,
                                      baseType: .debit,
                                      billID: Int64(arc4random()),
                                      billPaymentID: Int64(arc4random()),
                                      budgetCategory: .living,
                                      categoryID: Int64(arc4random()),
                                      description: description,
                                      included: true,
                                      memo: UUID().uuidString,
                                      merchantID: Int64(arc4random()),
                                      postDate: "2018-08-05",
                                      status: .posted,
                                      transactionDate: "2018-08-03")
    }
    
    static func testIncompleteData() -> APITransactionResponse {
        let amount = Amount(amount: "186.99",
                            currency: "AUD")
        let description = Description(original: UUID().uuidString,
                                      simple: nil,
                                      user: nil)
        
        return APITransactionResponse(id: Int64(arc4random()),
                                      accountID: Int64(arc4random()),
                                      amount: amount,
                                      baseType: .debit,
                                      billID: nil,
                                      billPaymentID: nil,
                                      budgetCategory: .living,
                                      categoryID: Int64(arc4random()),
                                      description: description,
                                      included: true,
                                      memo: nil,
                                      merchantID: Int64(arc4random()),
                                      postDate: nil,
                                      status: .posted,
                                      transactionDate: "2018-08-03")
    }
    
}
