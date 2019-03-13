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

extension MessageText {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `MessageText` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageText> {
        return NSFetchRequest<MessageText>(entityName: "MessageText")
    }
    
    /// Design type indicating how the message should be rendered
    @NSManaged public var designType: String
    
    /// Footer content (optional)
    @NSManaged public var footer: String?
    
    /// Header content (optional)
    @NSManaged public var header: String?
    
    /// Raw value of the image URL. Use only in predicates (optional)
    @NSManaged public var imageURLString: String?
    
    /// Text body content (optional)
    @NSManaged public var text: String?
    
}
