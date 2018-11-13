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
    public enum ContentType: String, Codable {
        
        /// The content is HTML and should be rendered in a `WKWebView`
        case html5
        
        /// The content contains text only and no image. Uses a standard `Design` type
        case text
        
        /// The content contains text and image. Uses a standard `Design` type
        case textAndImage = "text_and_image"
        
        /// The content contains a link to video content to be played
        case video
        
    }
    
    /**
     Design of the message
     
     Indicates what design should be used to render the image
    */
    public enum Design: String, Codable {
        
        /// Error banner
        case error
        
        /// Basic information
        case information
        
        /// Warning banner
        case warning
        
    }
    
    
    
    /// Core Data entity description name
    static var entityName = "Message"
    
    // MARK: Updating Object
    
    internal func linkObject(object: CacheableManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        // TODO: Implement
    }

}
