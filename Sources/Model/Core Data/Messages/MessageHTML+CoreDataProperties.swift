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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageHTML> {
        return NSFetchRequest<MessageHTML>(entityName: "MessageHTML")
    }

    
    @NSManaged public var footer: String?
    
    
    @NSManaged public var header: String?
    
    
    @NSManaged public var main: String

}
