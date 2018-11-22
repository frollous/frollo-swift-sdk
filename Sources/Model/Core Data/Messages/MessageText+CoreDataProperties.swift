//
//  MessageText+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension MessageText {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageText> {
        return NSFetchRequest<MessageText>(entityName: "MessageText")
    }

    
    @NSManaged public var designTypeRawValue: String
    
    
    @NSManaged public var footer: String?
    
    
    @NSManaged public var header: String?
    
    
    @NSManaged public var imageURLString: String?
    
    
    @NSManaged public var text: String?

}
