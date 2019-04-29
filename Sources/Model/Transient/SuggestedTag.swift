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

/**
 Represents a suggested tag from the API
 */
public class SuggestedTag {
    
    /// The name of the tag
    public let name: String
    
    /// The number of time this tag was used
    public let count: Int64?
    
    /// The date when this tag was last used
    public let lastUsedAt: Date?
    
    /// The date this tag was create at
    public let createdAt: Date?
    
    init(response: APITransactionTagResponse) {
        self.name = response.name
        self.count = response.count
        
        if let lastUsedAt = response.lastUsedAt {
            self.lastUsedAt = DateFormatter.dateOnly.date(from: lastUsedAt)
        } else {
            self.lastUsedAt = nil
        }
        
        if let createdAt = response.createdAt {
            self.createdAt = DateFormatter.dateOnly.date(from: createdAt)
        } else {
            self.createdAt = nil
        }
    }
}
