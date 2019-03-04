//
//  Bill+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

extension Bill {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Bill` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bill> {
        return NSFetchRequest<Bill>(entityName: "Bill")
    }
    
    /// Account ID bill is associated with
    @NSManaged public var accountID: Int64
    
    /// Average amount due
    @NSManaged public var averageAmount: NSDecimalNumber
    
    /// Unique ID of the bill
    @NSManaged public var billID: Int64
    
    /// Raw value of the bill type. Use only in predicates
    @NSManaged public var billTypeRawValue: String
    
    /// Additional details about the bill (Optional)
    @NSManaged public var details: String?
    
    /// Current due amount
    @NSManaged public var dueAmount: NSDecimalNumber
    
    /// Raw value of the end date. Use only in predicates (Optional)
    @NSManaged public var endDateString: String?
    
    /// Raw value of the frequency. Use only in predicates
    @NSManaged public var frequencyRawValue: String
    
    /// Last amount due (Optional)
    @NSManaged public var lastAmount: NSDecimalNumber?
    
    /// Raw value of the last payment date. Use only in predicates (Optional)
    @NSManaged public var lastPaymentDateString: String?
    
    /// Merchant ID bill is associated with
    @NSManaged public var merchantID: Int64
    
    /// Name of the bill (Optional)
    @NSManaged public var name: String?
    
    /// Raw value of the next payment due date. Use only in predicates
    @NSManaged public var nextPaymentDateString: String
    
    /// User notes about the bill (Optional)
    @NSManaged public var notes: String?
    
    /// Raw value of the bill payment status. Use only in predicates
    @NSManaged public var paymentStatusRawValue: String
    
    /// Raw value of the status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
    /// Transaction Category ID associated with the bill
    @NSManaged public var transactionCategoryID: Int64
    
    /// Account associated with the bill (Optional)
    @NSManaged public var account: Account?
    
    /// Merchant associated with the bill (Optional)
    @NSManaged public var merchant: Merchant?
    
    /// Transaction Category associated with the bill (Optional)
    @NSManaged public var transactionCategory: TransactionCategory?
    
    /// Child bill payments
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
