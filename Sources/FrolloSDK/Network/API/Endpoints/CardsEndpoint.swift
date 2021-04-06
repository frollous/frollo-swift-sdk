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

internal enum CardsEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    case card(cardID: Int64)
    case cards
    case publicKey
    case activate(cardID: Int64)
    case setPin(cardID: Int64)
    case lock(cardID: Int64)
    case unlock(cardID: Int64)
    case replace(cardID: Int64)
    
    private func urlPath() -> String {
        switch self {
            case .card(let cardID):
                return "cards/" + String(cardID)
            case .cards:
                return "cards"
            case .publicKey:
                return "cards/public_key"
            case .activate(let cardID):
                return "cards/" + String(cardID) + "/activate"
            case .setPin(let cardID):
                return "cards/" + String(cardID) + "/pin"
            case .lock(cardID: let cardID):
                return "cards/" + String(cardID) + "/lock"
            case .unlock(cardID: let cardID):
                return "cards/" + String(cardID) + "/unlock"
            case .replace(cardID: let cardID):
                return "cards/" + String(cardID) + "/replace"
        }
        
    }
    
}
