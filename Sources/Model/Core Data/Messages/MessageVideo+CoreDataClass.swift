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

/**
 Message Video
 
 Message with video content type and associated properties
 */
public class MessageVideo: Message {
    
    /// Video placeholder URL. The URL of an image to be displayed while the video content is paused or loading
    public var iconURL: URL? {
        get {
            if let rawValue = iconURLString {
                return URL(string: rawValue)
            }
            return nil
        }
        set {
            iconURLString = newValue?.absoluteString
        }
    }
    
    /// Video URL. URL of the video to be displayed
    public var url: URL {
        get {
            return URL(string: urlString)!
        }
        set {
            urlString = newValue.absoluteString
        }
    }
    
    internal override func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case .video(let contents)? = response.content
        else {
            return
        }
        
        autoplay = contents.autoplay
        autoplayCellular = contents.autoplayCellular
        muted = contents.muted
        height = contents.height ?? -1
        iconURLString = contents.iconURL
        urlString = contents.url
        width = contents.width ?? -1
    }
    
}
