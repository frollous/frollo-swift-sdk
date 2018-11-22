//
//  Message+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

/**
 Message
 
 Core Data represenation of a message
 */
public class Message: NSManagedObject, CacheableManagedObject {
    
    internal var primaryID: Int64 {
        get {
            return messageID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return nil
        }
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
     Design of the message
     
     Indicates what design should be used to render the image
    */
    public enum Design: String, CaseIterable, Codable {
        
        /// Error banner
        case error
        
        /// Basic information
        case information
        
        /// Warning banner
        case warning
        
    }
    
    /// Core Data entity description name
    static var entityName = "Message"
    
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
                return !type.isEmpty
            })
        }
        set {
            let typesString = newValue.joined(separator: "|")
            typesRawValue = "|" + typesString + "|"
        }
    }
    
    // MARK: Updating Object
    
    internal func linkObject(object: CacheableManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let messageResponse = response as? APIMessageResponse {
            update(response: messageResponse, context: context)
        }
    }
    
    internal func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        messageID = response.id
        clicked = response.clicked
        contentType = response.contentType
        event = response.event
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
        return APIMessageUpdateRequest(clicked: clicked,
                                       read: read)
    }

}
