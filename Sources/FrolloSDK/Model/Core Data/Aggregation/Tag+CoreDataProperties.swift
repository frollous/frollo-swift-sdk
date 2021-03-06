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
//

import CoreData
import Foundation

extension Tag {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Transaction` type
     */
    @nonobjc public class func tagFetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    /// The displayed name of the tag. This field is unique
    @NSManaged public var name: String
    
    /// The number of times this tag was used
    @NSManaged public var count: Int64
    
    /// The date this tag was last used
    @NSManaged public var lastUsedAt: Date?
    
    /// The date this tag was created
    @NSManaged public var createdAt: Date?
    
}
