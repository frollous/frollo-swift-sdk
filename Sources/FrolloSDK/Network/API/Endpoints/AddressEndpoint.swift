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

internal enum AddressEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    case addresses
    case address(id: Int64)
    case addressAutocomplete(addressID: String)
    case addressesAutocomplete
    
    private func urlPath() -> String {
        switch self {
            case .addresses:
                return "addresses"
            case .address(let addressID):
                return "addresses/" + String(addressID)
            case .addressAutocomplete(let addressID):
                return "addresses/autocomplete/" + addressID
            case .addressesAutocomplete:
                return "addresses/autocomplete"
        }
    }
    
}
