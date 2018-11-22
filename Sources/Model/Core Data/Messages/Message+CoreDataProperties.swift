//
//  Message+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var messageID: Int64
    @NSManaged public var event: String?
    @NSManaged public var title: String?
    @NSManaged public var userEventID: Int64
    @NSManaged public var placement: Int64
    @NSManaged public var persists: Bool
    @NSManaged public var read: Bool
    @NSManaged public var clicked: Bool
    @NSManaged public var contentTypeRawValue: String?
    @NSManaged public var typesRawValue: String
    @NSManaged public var actionTitle: String?
    @NSManaged public var actionURLString: String?
    @NSManaged public var actionOpenExternal: Bool

}
