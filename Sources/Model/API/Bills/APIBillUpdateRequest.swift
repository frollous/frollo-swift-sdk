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

struct APIBillUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case billType = "bill_type"
        case dueAmount = "due_amount"
        case endDate = "end_date"
        case frequency
        case name
        case nextPaymentDate = "next_payment_date"
        case note
        case status
    }
    
    let billType: Bill.BillType
    let dueAmount: String
    let endDate: String?
    let frequency: Bill.Frequency
    let name: String?
    let nextPaymentDate: String
    let note: String?
    let status: Bill.Status
    
}
