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

struct APIBillResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case averageAmount = "average_amount"
        case billType = "bill_type"
        case category
        case description
        case dueAmount = "due_amount"
        case endDate = "end_date"
        case id
        case frequency
        case lastAmount = "last_amount"
        case lastPaymentDate = "last_payment_date"
        case merchant
        case name
        case nextPaymentDate = "next_payment_date"
        case note
        case paymentStatus = "payment_status"
        case status
    }
    
    struct Category: Codable {
        let id: Int64
        let name: String
    }
    
    struct Merchant: Codable {
        let id: Int64
        let name: String
    }
    
    var id: Int64
    let accountID: Int64?
    let averageAmount: String
    let billType: Bill.BillType
    let category: Category?
    let description: String?
    let dueAmount: String
    let endDate: String?
    let frequency: Bill.Frequency
    let lastAmount: String?
    let lastPaymentDate: String?
    let merchant: Merchant?
    let name: String
    let nextPaymentDate: String
    let note: String?
    let paymentStatus: Bill.PaymentStatus
    let status: Bill.Status
    
}
