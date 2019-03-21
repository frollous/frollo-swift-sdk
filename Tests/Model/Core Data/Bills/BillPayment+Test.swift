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

extension BillPayment: TestableCoreData {
    
    @objc func populateTestData() {
        billPaymentID = Int64.random(in: 1...Int64.max)
        billID = Int64.random(in: 1...Int64.max)
        name = String.randomString(range: 5...30)
        merchantID = Int64.random(in: 1...Int64.max)
        dateString = "2021-01-01"
        paymentStatus = Bill.PaymentStatus.allCases.randomElement()!
        frequency = Bill.Frequency.allCases.randomElement()!
        amount = NSDecimalNumber(string: "61.11")
    }
    
}
