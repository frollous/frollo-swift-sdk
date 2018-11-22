//
//  MessageVideo+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


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
