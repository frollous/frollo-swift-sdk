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
@testable import FrolloSDK

extension APIBillCreateRequest {
    
    static func testTransactionData() -> APIBillCreateRequest {
        return APIBillCreateRequest(accountID: nil,
                                    dueAmount: nil,
                                    frequency: Bill.Frequency.allCases.randomElement()!,
                                    name: String.randomString(range: 5...20),
                                    nextPaymentDate: "2020-03-01",
                                    notes: String.randomString(range: 10...100),
                                    transactionID: Int64.random(in: 1...10000000))
    }
    
    static func testManualData() -> APIBillCreateRequest {
        return APIBillCreateRequest(accountID: Int64.random(in: 1...1000000),
                                    dueAmount: "81.34",
                                    frequency: Bill.Frequency.allCases.randomElement()!,
                                    name: String.randomString(range: 5...20),
                                    nextPaymentDate: "2020-03-01",
                                    notes: String.randomString(range: 10...100),
                                    transactionID: nil)
    }
    
}
