//
//  MessageVideo+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

/**
 Message Video
 
 Message with video content type and associated properties
 */
public class MessageVideo: Message {
    
    /// Video placeholder URL. The URL of an image to be displayed while the video content is paused or loading
    public var iconURL: URL? {
        get {
            if let rawValue = iconURLString {
                return URL(string: rawValue)
            }
            return nil
        }
        set {
            iconURLString = newValue?.absoluteString
        }
    }
    
    /// Video URL. URL of the video to be displayed
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
        
        guard case .video(let contents)? = response.content
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
