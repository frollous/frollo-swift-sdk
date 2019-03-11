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

extension APIBillPaymentResponse {
    
    static func testCompleteData() -> APIBillPaymentResponse {
        return APIBillPaymentResponse(id: Int64.random(in: 1...1000000000),
                                      amount: "70.05",
                                      billID: Int64.random(in: 1...100000000),
                                      date: "2019-01-13",
                                      frequency: Bill.Frequency.allCases.randomElement()!,
                                      merchantID: Int64.random(in: 1...1000000),
                                      name: String.randomString(range: 5...30),
                                      paymentStatus: Bill.PaymentStatus.allCases.randomElement()!)
    }
    
}
