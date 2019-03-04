//
//  MessageHTML+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

/**
 Message HTML
 
 Message with HTML content type and associated properties
 */
public class MessageHTML: Message {
    
    internal override func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case .html(let contents)? = response.content
        else {
            return
        }
        
        footer = contents.footer
        header = contents.header
        main = contents.main
    }
    
}
