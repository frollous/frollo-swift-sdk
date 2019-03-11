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

extension APIBillResponse {
    
    static func testCompleteData() -> APIBillResponse {
        let category = Category(id: Int64.random(in: 1...100000),
                                name: String.randomString(range: 5...20))
        
        let merchant = Merchant(id: Int64.random(in: 1...100000),
                                name: String.randomString(range: 5...20))
        
        return APIBillResponse(id: Int64.random(in: 1...100000),
                               accountID: Int64.random(in: 1...100000),
                               averageAmount: "99.89",
                               billType: Bill.BillType.allCases.randomElement()!,
                               category: category,
                               description: String.randomString(range: 5...50),
                               dueAmount: "79.65",
                               endDate: "2022-01-01",
                               frequency: Bill.Frequency.allCases.randomElement()!,
                               lastAmount: "101.23",
                               lastPaymentDate: "2018-12-01",
                               merchant: merchant,
                               name: String.randomString(range: 5...50),
                               nextPaymentDate: "2019-01-01",
                               note: String.randomString(range: 10...200),
                               paymentStatus: Bill.PaymentStatus.allCases.randomElement()!,
                               status: Bill.Status.allCases.randomElement()!)
    }
    
}
