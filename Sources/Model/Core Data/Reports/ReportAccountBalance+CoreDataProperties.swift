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

extension ReportAccountBalance {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `ReportTransactionHistory` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportAccountBalance> {
        return NSFetchRequest<ReportAccountBalance>(entityName: "ReportAccountBalance")
    }
    
    /// Related account ID. -1 if none linked
    @NSManaged public var accountID: Int64
    
    /// Currency of the report. ISO 4217 code
    @NSManaged public var currency: String
    
    /// Raw value of the date. Use only in predicates
    @NSManaged public var dateString: String
    
    /// Raw value of the period. Use only in predicates
    @NSManaged public var periodRawValue: String
    
    /// Balance of the report
    @NSManaged public var value: NSDecimalNumber?
    
    /// Related account (Optional)
    @NSManaged public var account: Account?
    
}
