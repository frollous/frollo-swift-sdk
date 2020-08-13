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
import SwiftyJSON

/**
 Message
 
 Core Data represenation of a message
 */
public class Message: NSManagedObject, UniqueManagedObject {
    
    internal var primaryID: Int64 {
        return messageID
    }
    
    /**
     Content Type
     
     Indicates the content type of the message and how it should be rendered
     */
    public enum ContentType: String, CaseIterable, Codable {
        
        /// The content is HTML and should be rendered in a `WKWebView`
        case html
        
        /// The content contains an image. Fetch the image from the URL
        case image
        
        /// The content contains text only and no image. Uses a standard `Design` type
        case text
        
        /// The content contains a link to video content to be played
        case video
        
    }
    
    /**
     Open Mode
     
     Indicates the open mode of the link and how it should be opened
     */
    public enum OpenMode: String, CaseIterable, Codable {
        
        /// Opens the link internally using native web view and no user controls
        case internalOpen = "internal"
        
        /// Opens the link internally using native web view and navigation controls
        case internalNavigation = "internal_navigation"
        
        /// Opens the link internally using the secure web view - SFSafariViewController
        case internalSecure = "internal_secure"
        
        /// Opens the linkusing the native browser on the phone (or app if deeplink)
        case external
    }
    
    /// Core Data entity description name
    static var entityName = "Message"
    
    internal static var primaryKey = #keyPath(Message.messageID)
    
    /// Action URL. The URL the user should be taken to when interacting with a message. Can be a deeplink or web URL.
    public var actionURL: URL? {
        get {
            if let rawValue = actionURLString {
                return URL(string: rawValue)
            }
            return nil
        }
        set {
            actionURLString = newValue?.absoluteString
        }
    }
    
    /// Type of content the message contains, indicates `Message` subentity
    public var contentType: ContentType {
        get {
            return ContentType(rawValue: contentTypeRawValue!)!
        }
        set {
            contentTypeRawValue = newValue.rawValue
        }
    }
    
    /// Open mode of the link, indicates how the link should be opened
    public var messageOpenMode: OpenMode? {
        get {
            if let rawValue = openModeRawValue {
                return OpenMode(rawValue: rawValue)
            }
            return nil
        }
        set {
            openModeRawValue = newValue?.rawValue
        }
    }
    
    /// All message types the message should be displayed in
    public var messageTypes: [String] {
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
    
    /// Metadata - custom JSON to be stored with the message
    public var metadata: JSON {
        get {
            if let rawValue = metadataRawValue {
                do {
                    return try JSON(data: rawValue)
                } catch {
                    Log.error(error.localizedDescription)
                }
            }
            return [:]
        }
        set {
            do {
                metadataRawValue = try newValue.rawData()
            } catch {
                Log.error(error.localizedDescription)
                
                metadataRawValue = try? JSONSerialization.data(withJSONObject: [:], options: [])
            }
        }
    }
    
    // MARK: Updating Object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let messageResponse = response as? APIMessageResponse {
            update(response: messageResponse, context: context)
        }
    }
    
    internal func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        messageID = response.id
        contentType = response.contentType
        event = response.event
        interacted = response.interacted
        messageTypes = response.messageTypes
        persists = response.persists
        placement = response.placement
        read = response.read
        title = response.title
        userEventID = response.userEventID ?? -1
        autoDismiss = response.autoDismiss
        
        actionURLString = response.action?.link
        messageOpenMode = response.action?.openMode
        actionTitle = response.action?.title
        if let meta = response.metadata {
            metadata = meta
        }
    }
    
    internal func updateRequest() -> APIMessageUpdateRequest {
        return APIMessageUpdateRequest(interacted: interacted,
                                       read: read)
    }
    
}
