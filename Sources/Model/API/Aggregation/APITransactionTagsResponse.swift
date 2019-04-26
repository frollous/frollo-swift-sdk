//
//  Copyright © 2018 Frollo. All rights reserved.
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

struct APITransactionTagResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case count
        case lastUsedAt = "last_used_at"
        case createdAt = "created_at"
    }
    
    let name: String
    let count: Int64?
    let lastUsedAt: String?
    let createdAt: String?
}
