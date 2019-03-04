//
//  MessageText+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

extension MessageText {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `MessageText` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageText> {
        return NSFetchRequest<MessageText>(entityName: "MessageText")
    }
    
    /// Design type indicating how the message should be rendered
    @NSManaged public var designType: String
    
    /// Footer content (optional)
    @NSManaged public var footer: String?
    
    /// Header content (optional)
    @NSManaged public var header: String?
    
    /// Raw value of the image URL. Use only in predicates (optional)
    @NSManaged public var imageURLString: String?
    
    /// Text body content (optional)
    @NSManaged public var text: String?
    
}
