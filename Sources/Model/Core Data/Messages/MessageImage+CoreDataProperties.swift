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

extension MessageImage {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `MessageImage` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageImage> {
        return NSFetchRequest<MessageImage>(entityName: "MessageImage")
    }
    
    /// Height of the image in pixels
    @NSManaged public var height: Double
    
    /// Width of the image in pixels
    @NSManaged public var width: Double
    
    /// Raw value for the image URL
    @NSManaged public var urlString: String
    
}
