//
//  MessageImage+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension MessageImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageImage> {
        return NSFetchRequest<MessageImage>(entityName: "MessageImage")
    }

    @NSManaged public var height: Double
    @NSManaged public var width: Double
    @NSManaged public var urlString: String

}
