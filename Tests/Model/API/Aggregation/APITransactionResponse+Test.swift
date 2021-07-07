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
        
        let location = Merchant.Location(country: String.randomString(range: 1...50),
                                         formattedAddress: String.randomString(range: 1...100),
                                         latitude: Double.random(in: 0...90),
                                         line1: String.randomString(range: 1...50),
                                         line2: String.randomString(range: 1...50),
                                         line3: String.randomString(range: 1...50),
                                         longitude: Double.random(in: 0...90),
                                         postcode: String.randomString(length: 4),
                                         state: String.randomString(range: 1...50),
                                         suburb: String.randomString(range: 1...50))
        
        let merchant = Merchant(id: Int64.random(in: 1...Int64.max),
                                location: location,
                                name: String.randomString(range: 1...50),
                                phone: String.randomString(length: 9),
                                website: String.randomString(range: 10...100))
        let category = Category(id: Int64.random(in: 1...Int64.max),
                                name: String.randomString(range: 1...50),
                                imageURL: "https://example.com/category.png")
        
        return APITransactionResponse(id: Int64.random(in: 1...Int64.max),
                                      accountID: Int64.random(in: 1...Int64.max),
                                      amount: amount,
                                      baseType: .debit,
                                      billID: Int64.random(in: 1...Int64.max),
                                      billPaymentID: Int64.random(in: 1...Int64.max),
                                      budgetCategory: .living,
                                      category: category,
                                      description: description,
                                      externalID: UUID().uuidString,
                                      goalID: Int64.random(in: 1...Int64.max),
                                      included: true,
                                      memo: UUID().uuidString,
                                      merchant: merchant,
                                      postDate: "2018-08-05",
                                      status: .posted,
                                      transactionDate: "2018-08-03",
                                      userTags: ["tag1", "tag2"])
    }
    
    static func testIncompleteData() -> APITransactionResponse {
        let amount = Amount(amount: "186.99",
                            currency: "AUD")
        let description = Description(original: UUID().uuidString,
                                      simple: nil,
                                      user: nil)
        
        let merchant = Merchant(id: Int64.random(in: 1...Int64.max),
                                location: nil,
                                name: String.randomString(range: 5...50),
                                phone: nil,
                                website: nil)

        let category = Category(id: Int64.random(in: 1...Int64.max),
                                name: String.randomString(range: 1...50),
                                imageURL: "https://example.com/category.png")
        
        return APITransactionResponse(id: Int64.random(in: 1...Int64.max),
                                      accountID: Int64.random(in: 1...Int64.max),
                                      amount: amount,
                                      baseType: .debit,
                                      billID: nil,
                                      billPaymentID: nil,
                                      budgetCategory: .living,
                                      category: category,
                                      description: description,
                                      externalID: UUID().uuidString,
                                      goalID: Int64.random(in: 1...Int64.max),
                                      included: true,
                                      memo: nil,
                                      merchant: merchant,
                                      postDate: nil,
                                      status: .posted,
                                      transactionDate: "2018-08-03",
                                      userTags: ["tag1", "tag2"])
    }
    
}
