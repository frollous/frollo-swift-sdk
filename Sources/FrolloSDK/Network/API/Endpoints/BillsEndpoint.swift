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

enum BillsEndpoint: Endpoint {
    
    enum QueryParameters: String, Codable {
        case fromDate = "from_date"
        case toDate = "to_date"
    }
    
    internal var path: String {
        return urlPath()
    }
    
    case bill(billID: Int64)
    case bills
    case billPayment(billPaymentID: Int64)
    case billPayments
    
    private func urlPath() -> String {
        switch self {
            case .bill(let billID):
                return "bills/" + String(billID)
            case .bills:
                return "bills"
            case .billPayment(let billPaymentID):
                return "bills/payments/" + String(billPaymentID)
            case .billPayments:
                return "bills/payments"
        }
    }
    
}
