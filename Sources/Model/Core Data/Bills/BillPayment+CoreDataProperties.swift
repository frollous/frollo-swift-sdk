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
