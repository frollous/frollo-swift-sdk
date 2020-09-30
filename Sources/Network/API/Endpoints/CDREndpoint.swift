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

enum CDREndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    enum QueryParameters: String, Codable {
        case accountID = "account_id"
    }
    
    static var consents: CDREndpoint {
        return CDREndpoint.consents(id: nil)
    }
    
    case consents(id: Int64?)
    case products
    case configuration
    
    private func urlPath() -> String {
        switch self {
            case .consents(let id):
                if let id = id {
                    return "cdr/consents/\(id)"
                } else {
                    return "cdr/consents"
                }
            case .products:
                return "cdr/products"
            case .configuration:
                return "cdr/configuration"
        }
    }
    
}
