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
    let lastUsedAt: Date?
    let createdAt: Date?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        count = try values.decodeIfPresent(Int64.self, forKey: .count)
        if let lastUsedAtString = try values.decodeIfPresent(String.self, forKey: .lastUsedAt) {
            self.lastUsedAt = DateFormatter.iso8601Milliseconds.date(from: lastUsedAtString)
        } else {
            self.lastUsedAt = nil
        }
        
        if let createdAtString = try values.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = DateFormatter.iso8601Milliseconds.date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(count, forKey: .count)
        var lastUsedAtString: String?
        if let lastUsedAt = lastUsedAt {
            lastUsedAtString = DateFormatter.iso8601Milliseconds.string(from: lastUsedAt)
        }
        try container.encodeIfPresent(lastUsedAtString, forKey: .lastUsedAt)
        
        var createdAtString: String?
        if let createdAt = createdAt {
            createdAtString = DateFormatter.iso8601Milliseconds.string(from: createdAt)
        }
        try container.encodeIfPresent(createdAtString, forKey: .createdAt)
    }
    
}
