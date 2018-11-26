//
//  MessageText+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

/**
 Message Text
 
 Message with text content type and associated properties
 */
public class MessageText: Message {
    
    /// Image URL. The URL of an image to be displayed
    public var imageURL: URL? {
        get {
            if let rawValue = imageURLString {
                return URL(string: rawValue)
            }
            return nil
        }
        set {
            imageURLString = newValue?.absoluteString
        }
    }

    internal override func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case let .text(contents)? = response.content
            else {
                return
        }
        
        designType = contents.designType
        footer = contents.footer
        header = contents.header
        imageURLString = contents.imageURL
        text = contents.text
    }
    
}
