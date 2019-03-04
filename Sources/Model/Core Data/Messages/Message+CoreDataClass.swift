//
//  Message+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

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
    
    /// All message types the message should be displayed in
    public var messageTypes: [String] {
        get {
            let types = typesRawValue.components(separatedBy: "|")
            return types.filter({ (type) -> Bool in
                !type.isEmpty
            })
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
        
        actionURLString = response.action?.link
        actionOpenExternal = response.action?.openExternal ?? false
        actionTitle = response.action?.title
    }
    
    internal func updateRequest() -> APIMessageUpdateRequest {
        return APIMessageUpdateRequest(interacted: interacted,
                                       read: read)
    }
    
}
