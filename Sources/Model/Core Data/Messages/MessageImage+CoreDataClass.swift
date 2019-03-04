//
//  MessageImage+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
