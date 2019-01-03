//
//  Bill+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 18/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

public class Bill: NSManagedObject, CacheableManagedObject {
    
    public enum BillType: String, Codable, CaseIterable {
        case bill
        case manual
        case repayment
        case subscription
    }
    
    public enum Frequency: String, Codable, CaseIterable {
        case annually
        case biannually
        case fortnightly
        case fourWeekly = "four_weekly"
        case irregular
        case monthly
        case quarterly
        case weekly
        case unknown
    }
    
    public enum PaymentStatus: String, Codable, CaseIterable {
        case due
        case future
        case overdue
        case paid
    }
    
    public enum Status: String, Codable, CaseIterable {
        case confirmed
        case estimated
    }
    
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
            return billID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    public var billType: BillType {
        get {
            return BillType(rawValue: billTypeRawValue)!
        }
        set {
            billTypeRawValue = newValue.rawValue
        }
    }
    
    public var frequency: Frequency {
        get {
            return Frequency(rawValue: frequencyRawValue)!
        }
        set {
            frequencyRawValue = newValue.rawValue
        }
    }
    
    public var paymentStatus: PaymentStatus {
        get {
            return PaymentStatus(rawValue: paymentStatusRawValue)!
        }
        set {
            paymentStatusRawValue = newValue.rawValue
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    public var lastPaymentDate: Date? {
        get {
            if let rawDateString = lastPaymentDateString {
                return Bill.billDateFormatter.date(from: rawDateString)
            }
            return nil
        }
        set {
            if let newRawDate = newValue {
                lastPaymentDateString = Bill.billDateFormatter.string(from: newRawDate)
            } else {
                lastPaymentDateString = nil
            }
        }
    }
    
    public var nextPaymentDate: Date? {
        get {
            return Bill.billDateFormatter.date(from: nextPaymentDateString)!
        }
        set {
            nextPaymentDateString = Bill.billDateFormatter.string(from: newValue!)
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: CacheableManagedObject) {
        if let billPayment = object as? BillPayment {
            addToPayments(billPayment)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let billResponse = response as? APIBillResponse {
            update(response: billResponse, context: context)
        }
    }
    
    internal func update(response: APIBillResponse, context: NSManagedObjectContext) {
        billID = response.id
        accountID = response.accountID ?? -1
        averageAmount = NSDecimalNumber(string: response.averageAmount)
        billType = response.billType
        details = response.description
        dueAmount = NSDecimalNumber(string: response.dueAmount)
        frequency = response.frequency
        lastAmount = NSDecimalNumber(string: response.lastAmount)
        lastPaymentDateString = response.lastPaymentDate
        merchantID = response.merchant?.id ?? -1
        name = response.name
        nextPaymentDateString = response.nextPaymentDate
        notes = response.note
        paymentStatus = response.paymentStatus
        status = response.status
        transactionCategoryID = response.category?.id ?? -1
    }
    
    internal func updateRequest() -> APIBillUpdateRequest {
        return APIBillUpdateRequest(billType: billType,
                                    dueAmount: dueAmount.stringValue,
                                    frequency: frequency,
                                    name: name,
                                    nextPaymentDate: nextPaymentDateString,
                                    note: notes,
                                    status: status)
    }

}
