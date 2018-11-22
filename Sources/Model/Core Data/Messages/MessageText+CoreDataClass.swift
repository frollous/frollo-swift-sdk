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


public class MessageText: Message {
    
    /// Design type of text nudges
    public var designType: Design {
        get {
            return Design(rawValue: designTypeRawValue)!
        }
        set {
            designTypeRawValue = newValue.rawValue
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
