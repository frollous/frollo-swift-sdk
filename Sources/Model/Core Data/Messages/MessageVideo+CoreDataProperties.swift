//
//  MessageVideo+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension MessageVideo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageVideo> {
        return NSFetchRequest<MessageVideo>(entityName: "MessageVideo")
    }

    @NSManaged public var height: Double
    @NSManaged public var width: Double
    @NSManaged public var muted: Bool
    @NSManaged public var autoplay: Bool
    @NSManaged public var autoplayCellular: Bool

}
