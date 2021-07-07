//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

import CoreData
import Foundation

/**
 Bill
 
 Core Data model of the bill.
 */
public class Bill: NSManagedObject, UniqueManagedObject {
    
    /**
     Bill Type
     
     Detailed type of bill
     */
    public enum BillType: String, Codable, CaseIterable {
        
        /// General bill
        case bill
        
        /// Manually entered bill
        case manual
        
        /// Repayment, e.g. of a debt
        case repayment
        
        /// Recurring subscription
        case subscription
        
    }
    
    /**
     Frequency
     
     How often the `BillPayment`s occur
     */
    public enum Frequency: String, Codable, CaseIterable {
        
        /// Annually
        case annually
        
        /// Biannually - twice in a year
        case biannually
        
        /// Fortnightly
        case fortnightly
        
        /// Every four weeks
        case fourWeekly = "four_weekly"
        
        /// Irregularly
        case irregular
        
        /// Monthly
        case monthly
        
        /// Quarterly
        case quarterly
        
        /// Weekly
        case weekly
        
        /// Unknown
        case unknown
        
    }
    
    /**
     Payment Status
     
     Status of the latest bill payment
     */
    public enum PaymentStatus: String, Codable, CaseIterable {
        
        /// Payment is due
        case due
        
        /// Payment is in the future
        case future
        
        /// Payment is overdue
        case overdue
        
        /// Paid
        case paid
        
    }
    
    /**
     Bill Status
     
     Status of the bill indicating if the user has confirmed it or not
     */
    public enum Status: String, Codable, CaseIterable {
        
        /// Confirmed
        case confirmed
        
        /// Estimated from repeat transactions that have been detected
        case estimated
        
    }
    
    /// Core Data entity description name
    static var entityName = "Bill"
    
    internal static var primaryKey = #keyPath(Bill.billID)
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let billDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        return billID
    }
    
    /// Bill Type
    public var billType: BillType {
        get {
            return BillType(rawValue: billTypeRawValue)!
        }
        set {
            billTypeRawValue = newValue.rawValue
        }
    }
    
    /// Frequency
    public var frequency: Frequency {
        get {
            return Frequency(rawValue: frequencyRawValue)!
        }
        set {
            frequencyRawValue = newValue.rawValue
        }
    }
    
    /// Bill Payment Status
    public var paymentStatus: PaymentStatus {
        get {
            return PaymentStatus(rawValue: paymentStatusRawValue)!
        }
        set {
            paymentStatusRawValue = newValue.rawValue
        }
    }
    
    /// Bill Status
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Date the bill terminates, e.g. a subscription (Optional)
    public var endDate: Date? {
        get {
            if let rawDateString = endDateString {
                return Bill.billDateFormatter.date(from: rawDateString)
            }
            return nil
        }
        set {
            if let newRawDate = newValue {
                endDateString = Bill.billDateFormatter.string(from: newRawDate)
            } else {
                endDateString = nil
            }
        }
    }
    
    /// Last payment date (Optional)
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
    
    /// Next Payment Date
    public var nextPaymentDate: Date {
        get {
            return Bill.billDateFormatter.date(from: nextPaymentDateString)!
        }
        set {
            nextPaymentDateString = Bill.billDateFormatter.string(from: newValue)
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
        if let billPayment = object as? BillPayment {
            addToPayments(billPayment)
        }
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
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
        endDateString = response.endDate
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
                                    endDate: endDateString,
                                    frequency: frequency,
                                    name: name,
                                    nextPaymentDate: nextPaymentDateString,
                                    note: notes,
                                    status: status)
    }
    
}
