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
    @NSManaged public var userEventID: Int64
    @NSManaged public var placement: Int64
    @NSManaged public var persists: Bool
    @NSManaged public var read: Bool
    @NSManaged public var clicked: Bool
    @NSManaged public var designTypeRawValue: String?
    @NSManaged public var contentTypeRawValue: String?
    @NSManaged public var actionTitle: String?
    @NSManaged public var actionURLString: String?
    @NSManaged public var actionOpenExternal: Bool
    @NSManaged public var buttonTitle: String?
    @NSManaged public var buttonURLString: String?
    @NSManaged public var buttonOpenExternal: Bool
    @NSManaged public var typeHome: Bool
    @NSManaged public var typePopup: Bool
    @NSManaged public var typeSetup: Bool
    @NSManaged public var typeGoal: Bool
    @NSManaged public var typeFeed: Bool
    @NSManaged public var typeCreditScore: Bool

}
