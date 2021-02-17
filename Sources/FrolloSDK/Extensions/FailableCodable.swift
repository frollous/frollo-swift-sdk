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

internal struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            self.base = try container.decode(Base.self)
        } catch {
            Log.error(error.localizedDescription)
            
            self.base = nil
        }
    }
}

/**
 Failable Codable Array
 
 Allows iterating through a Decodable array and handling invalid objects without dropping the entire data set
 */
internal struct FailableCodableArray<Element: Decodable>: Decodable {
    
    private(set) var elements: [Element]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        
        while !container.isAtEnd {
            guard let element = try container.decode(FailableDecodable<Element>.self).base else {
                continue
            }
            
            elements.append(element)
        }
        
        self.elements = elements
    }
    
}
