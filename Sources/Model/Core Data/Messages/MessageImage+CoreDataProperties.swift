//
//  MessageImage+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
