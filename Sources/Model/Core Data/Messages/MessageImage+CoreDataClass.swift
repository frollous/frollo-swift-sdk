//
//  MessageImage+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


public class MessageImage: Message {

    internal override func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case let .image(contents)? = response.content
            else {
                return
        }
        
        urlString = contents.url
        height = contents.height
        width = contents.width
    }
    
}
