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

extension MessageVideo {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `MessageVideo` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageVideo> {
        return NSFetchRequest<MessageVideo>(entityName: "MessageVideo")
    }
    
    /// Height in pixels of the video
    @NSManaged public var height: Double
    
    /// Width in pixels of the video
    @NSManaged public var width: Double
    
    /// Default mute state of the video
    @NSManaged public var muted: Bool
    
    /// Video should autoplay
    @NSManaged public var autoplay: Bool
    
    /// Video should autoplay while the device is on cellular data
    @NSManaged public var autoplayCellular: Bool
    
    /// Raw value for the placeholder image to display while video is loading (optional)
    @NSManaged public var iconURLString: String?
    
    /// Raw value for the video URL
    @NSManaged public var urlString: String
    
}
