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

extension Bill: TestableCoreData {
    
    @objc func populateTestData() {
        billID = Int64.random(in: 1...100000)
        accountID = Int64.random(in: 1...100000)
        averageAmount = 400.13
        billType = BillType.allCases.randomElement()!
        details = String.randomString(range: 5...50)
        dueAmount = 43.12
        endDateString = "2022-01-01"
        frequency = Frequency.allCases.randomElement()!
        lastAmount = 61.90
        lastPaymentDateString = "2018-12-13"
        merchantID = Int64.random(in: 1...100000)
        name = String.randomString(range: 5...20)
        nextPaymentDateString = "2019-02-13"
        notes = String.randomString(range: 20...200)
        paymentStatus = PaymentStatus.allCases.randomElement()!
        status = Status.allCases.randomElement()!
    }
    
}
