//
//  MessageVideo+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


public class MessageVideo: Message {
    
    internal override func update(response: APIMessageResponse, context: NSManagedObjectContext) {
        super.update(response: response, context: context)
        
        guard case let .video(contents)? = response.content
            else {
                return
        }
        
        autoplay = contents.autoplay
        autoplayCellular = contents.autoplayCellular
        muted = contents.muted
        height = contents.height ?? -1
        iconURLString = contents.iconURL
        urlString = contents.url
        width = contents.width ?? -1
    }

}
