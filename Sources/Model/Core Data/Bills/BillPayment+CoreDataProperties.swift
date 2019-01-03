//
//  BillPayment+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 3/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension BillPayment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BillPayment> {
        return NSFetchRequest<BillPayment>(entityName: "BillPayment")
    }

    @NSManaged public var billPaymentID: Int64
    @NSManaged public var billID: Int64
    @NSManaged public var name: String
    @NSManaged public var merchantID: Int64
    @NSManaged public var dateString: String
    @NSManaged public var paymentStatusRawValue: String
    @NSManaged public var frequencyRawValue: String
    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var bill: Bill?

}
