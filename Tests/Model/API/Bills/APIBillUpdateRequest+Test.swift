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

extension APIBillUpdateRequest {
    
    static func testCompleteData() -> APIBillUpdateRequest {
        return APIBillUpdateRequest(billType: Bill.BillType.allCases.randomElement()!,
                                    dueAmount: "30.53",
                                    endDate: "2022-01-01",
                                    frequency: Bill.Frequency.allCases.randomElement()!,
                                    name: String.randomString(range: 5...30),
                                    nextPaymentDate: "2020-01-20",
                                    note: String.randomString(range: 5...200),
                                    status: Bill.Status.allCases.randomElement()!)
    }
    
}
