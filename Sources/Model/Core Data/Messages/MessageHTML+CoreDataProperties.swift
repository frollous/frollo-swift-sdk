//
//  MessageHTML+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension MessageHTML {

    /**
     Fetch Request
     
     - returns: Fetch request for `MessageHTML` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageHTML> {
        return NSFetchRequest<MessageHTML>(entityName: "MessageHTML")
    }

    /// Footer content (optional)
    @NSManaged public var footer: String?
    
    /// Header content (optional)
    @NSManaged public var header: String?
    
    /// HTML content to be rendered
    @NSManaged public var main: String

}
