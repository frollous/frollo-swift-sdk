//
//  Bill+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension Bill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bill> {
        return NSFetchRequest<Bill>(entityName: "Bill")
    }

    @NSManaged public var accountID: Int64
    @NSManaged public var averageAmount: NSDecimalNumber
    @NSManaged public var billID: Int64
    @NSManaged public var billTypeRawValue: String
    @NSManaged public var details: String?
    @NSManaged public var dueAmount: NSDecimalNumber
    @NSManaged public var frequencyRawValue: String
    @NSManaged public var lastAmount: NSDecimalNumber?
    @NSManaged public var lastPaymentDateString: String?
    @NSManaged public var merchantID: Int64
    @NSManaged public var name: String?
    @NSManaged public var nextPaymentDateString: String
    @NSManaged public var notes: String?
    @NSManaged public var paymentStatusRawValue: String
    @NSManaged public var statusRawValue: String
    @NSManaged public var transactionCategoryID: Int64
    @NSManaged public var account: Account?
    @NSManaged public var merchant: Merchant?
    @NSManaged public var transactionCategory: TransactionCategory?
    @NSManaged public var payments: Set<BillPayment>?

}

// MARK: Generated accessors for payments
extension Bill {
    
    /// Add a payment relationship
    @objc(addPaymentsObject:)
    @NSManaged public func addToPayments(_ value: BillPayment)
    
    /// Remove a payment relationship
    @objc(removePaymentsObject:)
    @NSManaged public func removeFromPayments(_ value: BillPayment)
    
    /// Add payment relationships
    @objc(addPayments:)
    @NSManaged public func addToPayments(_ values: Set<BillPayment>)
    
    /// Remove payment relationships
    @objc(removePayments:)
    @NSManaged public func removeFromPayments(_ values: Set<BillPayment>)
    
}
