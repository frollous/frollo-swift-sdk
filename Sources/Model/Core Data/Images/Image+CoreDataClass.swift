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
 User Model
 
 Stores information about the user and their profile
 */
public class Image: NSManagedObject, UniqueManagedObject {
    
    static var entityName: String = "Image"
    
    static var primaryKey = #keyPath(Image.imageID)
    
    var primaryID: Int64 {
        return imageID
    }
    
    /// URL to the small image
    public var smallURL: URL {
        get {
            return URL(string: smallURLString)!
        }
        set {
            smallURLString = newValue.absoluteString
        }
    }
    
    /// URL to the large image
    public var largeURL: URL {
        get {
            return URL(string: largeURLString)!
        }
        set {
            largeURLString = newValue.absoluteString
        }
    }
    
    /// All image types the image should be displayed in
    public var imageTypes: [String] {
        get {
            let types = typesRawValue.components(separatedBy: "|")
            return types.filter { (type) -> Bool in
                !type.isEmpty
            }
        }
        set {
            let typesString = newValue.joined(separator: "|")
            typesRawValue = "|" + typesString + "|"
        }
    }
    
    // MARK: Updating Object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let messageResponse = response as? APIImageResponse {
            update(response: messageResponse, context: context)
        }
    }
    
    internal func update(response: APIImageResponse, context: NSManagedObjectContext) {
        imageID = response.id
        name = response.name
        smallURLString = response.smallImageURL
        largeURLString = response.largeImageURL
        imageTypes = response.imageTypes
    }
}
