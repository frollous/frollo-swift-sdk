//
//  ReportAccountBalance+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 25/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportAccountBalance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportAccountBalance> {
        return NSFetchRequest<ReportAccountBalance>(entityName: "ReportAccountBalance")
    }

    @NSManaged public var periodRawValue: String
    @NSManaged public var dateString: String
    @NSManaged public var value: NSDecimalNumber?
    @NSManaged public var accountID: Int64
    @NSManaged public var account: Account?

}
