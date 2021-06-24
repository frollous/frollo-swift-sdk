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

enum UserEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    enum QueryParameters: String, Codable {
        case query
        case max
    }
    
    case details
    case migrate
    case register
    case resetPassword
    case user
    case requestOTP
    case unconfirmedDetails
    case confirmDetails
    case payID
    case removePayID
    case payIDOTP
    case accountPayID(accountID: Int64)
    
    private func urlPath() -> String {
        switch self {
            case .details:
                return "user/details"
            case .migrate:
                return "user/migrate"
            case .register:
                return "user/register"
            case .resetPassword:
                return "user/reset"
            case .user:
                return "user"
            case .requestOTP:
                return "user/otp"
            case .unconfirmedDetails, .confirmDetails:
                return "user/details/confirm"
            case .payID:
                return "user/payid"
            case .removePayID:
                return "user/payid/remove"
            case .payIDOTP:
                return "user/payid/otp"
            case .accountPayID(let accountID):
                return "user/payid/account/" + String(accountID)
        }
    }
    
}
