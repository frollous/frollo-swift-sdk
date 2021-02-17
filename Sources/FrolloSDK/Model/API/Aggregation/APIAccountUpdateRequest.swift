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

struct APIAccountUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountType = "account_type"
        case favourite
        case hidden
        case included
        case nickName = "nick_name"
        case productID = "product_id"
    }
    
    let accountType: Account.AccountSubType?
    let favourite: Bool?
    let hidden: Bool
    let included: Bool
    let nickName: String?
    let productID: Int64?
    
    var valid: Bool {
        return !(hidden && included)
    }
    
}
