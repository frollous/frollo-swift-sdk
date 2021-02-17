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
 Message Image
 
 Message with image content type and associated properties
 */
public class MessageImage: Message {
    
    /// Image URL. URL of the image to be displayed
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
        
        guard case .image(let contents)? = response.content
        else {
            return
        }
        
        urlString = contents.url
        height = contents.height
        width = contents.width
    }
    
}
