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

extension Message {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Message` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }
    
    /// Unique identifier of the message
    @NSManaged public var messageID: Int64
    
    /// Event name associated with the message
    @NSManaged public var event: String
    
    /// Title of the message (optional)
    @NSManaged public var title: String?
    
    /// Unique ID of the user event associated with the message
    @NSManaged public var userEventID: Int64
    
    /// Placement order of the message - higher is more important
    @NSManaged public var placement: Int64
    
    /// Persists. Indicates if the message can be marked read or not
    @NSManaged public var persists: Bool
    
    /// Read/unread state
    @NSManaged public var read: Bool
    
    /// Interacted. Should be updated if the user interacted with the message
    @NSManaged public var interacted: Bool
    
    /// Raw value for the content type. Use only in predicates (optional)
    @NSManaged public var contentTypeRawValue: String?
    
    /// Raw value for the types the message is associated with. Use only in predicates using `CONTAINS '|<type>|'` to ensure unique matches (optional)
    @NSManaged public var typesRawValue: String
    
    /// Title of the action (optional)
    @NSManaged public var actionTitle: String?
    
    /// Raw value of the action URL. Use only in predicates (optional)
    @NSManaged public var actionURLString: String?
    
    /// Action should open the link externally or internally. Externally means the system should handle opening the link.
    @NSManaged public var actionOpenExternal: Bool
    
}
