//
//  BillPayment+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 3/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


public class BillPayment: NSManagedObject, CacheableManagedObject {

    /// Core Data entity description name
    static var entityName = "Bill"
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let billDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        get {
            return billPaymentID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return billID
        }
    }
    
    public var date: Date? {
        get {
            return BillPayment.billDateFormatter.date(from: dateString)!
        }
        set {
            dateString = BillPayment.billDateFormatter.string(from: newValue!)
        }
    }
    
    public var frequency: Bill.Frequency {
        get {
            return Bill.Frequency(rawValue: frequencyRawValue)!
        }
        set {
            frequencyRawValue = newValue.rawValue
        }
    }
    
    public var paymentStatus: Bill.PaymentStatus {
        get {
            return Bill.PaymentStatus(rawValue: paymentStatusRawValue)!
        }
        set {
            paymentStatusRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: CacheableManagedObject) {
        // Not used
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let billPaymentResponse = response as? APIBillPaymentResponse {
            update(response: billPaymentResponse, context: context)
        }
    }
    
    internal func update(response: APIBillPaymentResponse, context: NSManagedObjectContext) {
        billPaymentID = response.id
        amount = NSDecimalNumber(string: response.amount)
        billID = response.billID
        dateString = response.date
        frequency = response.frequency
        merchantID = response.merchantID
        name = response.name
        paymentStatus = response.paymentStatus
    }
    
}
