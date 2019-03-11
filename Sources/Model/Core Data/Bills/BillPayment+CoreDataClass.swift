//
// Copyright © 2019 Frollo. All rights reserved.
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
 Bill Payment
 
 Core Data model of the bill payment.
 */
public class BillPayment: NSManagedObject, UniqueManagedObject {
    
    /// Core Data entity description name
    static var entityName = "BillPayment"
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let billDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    internal var primaryID: Int64 {
        return billPaymentID
    }
    
    internal static var primaryKey = #keyPath(BillPayment.billPaymentID)
    
    /// Date of the bill payment
    public var date: Date {
        get {
            return BillPayment.billDateFormatter.date(from: dateString)!
        }
        set {
            dateString = BillPayment.billDateFormatter.string(from: newValue)
        }
    }
    
    /// Frequency the bill payment occurs
    public var frequency: Bill.Frequency {
        get {
            return Bill.Frequency(rawValue: frequencyRawValue)!
        }
        set {
            frequencyRawValue = newValue.rawValue
        }
    }
    
    /// Status of the bill payment
    public var paymentStatus: Bill.PaymentStatus {
        get {
            return Bill.PaymentStatus(rawValue: paymentStatusRawValue)!
        }
        set {
            paymentStatusRawValue = newValue.rawValue
        }
    }
    
    // MARK: - Updating object
    
    internal func linkObject(object: NSManagedObject) {
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
    
    internal func updateRequest() -> APIBillPaymentUpdateRequest {
        return APIBillPaymentUpdateRequest(status: paymentStatus)
    }
    
}
