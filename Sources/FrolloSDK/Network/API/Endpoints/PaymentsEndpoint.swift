//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

internal enum PaymentsEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    case bpay
    case payAnyone
    case transfers
    case payID
    case npp
    case verifyPayAnyone
    case verifyPayID
    case verifyBPAY
    
    private func urlPath() -> String {
        switch self {
            case .bpay:
                return "payments/bpay"
            case .payAnyone:
                return "payments/payanyone"
            case .transfers:
                return "payments/transfer"
            case .payID:
                return "payments/payid"
            case .npp:
                return "payments/npp"
            case .verifyPayAnyone:
                return "payments/verify/pay_anyone"
            case .verifyPayID:
                return "payments/verify/payid"
            case .verifyBPAY:
                return "payments/verify/bpay"
        }
    }
    
}
