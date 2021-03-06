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

struct APIBillPaymentResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case billID = "bill_id"
        case date
        case frequency
        case id
        case merchantID = "merchant_id"
        case name
        case paymentStatus = "payment_status"
    }
    
    var id: Int64
    let amount: String
    let billID: Int64
    let date: String
    let frequency: Bill.Frequency
    let merchantID: Int64
    let name: String
    let paymentStatus: Bill.PaymentStatus
    
}
