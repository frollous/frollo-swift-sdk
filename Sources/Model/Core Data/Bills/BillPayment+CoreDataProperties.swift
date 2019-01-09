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

    /**
     Fetch Request
     
     - returns: Fetch request for `BillPayment` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BillPayment> {
        return NSFetchRequest<BillPayment>(entityName: "BillPayment")
    }

    /// Unique ID of the bill payment
    @NSManaged public var billPaymentID: Int64
    
    /// Bill ID of the parent bill
    @NSManaged public var billID: Int64
    
    /// Name of the bill
    @NSManaged public var name: String
    
    /// Merchant ID associated with the bill payment
    @NSManaged public var merchantID: Int64
    
    /// Raw value of the date. Use only in predicates
    @NSManaged public var dateString: String
    
    /// Raw value of the payment status. Use only in predicates
    @NSManaged public var paymentStatusRawValue: String
    
    /// Raw value of the frequency of bill payments. Use only in predicates
    @NSManaged public var frequencyRawValue: String
    
    /// Amount of the payment (Optional)
    @NSManaged public var amount: NSDecimalNumber?
    
    /// Parent bill (Optional)
    @NSManaged public var bill: Bill?

}
