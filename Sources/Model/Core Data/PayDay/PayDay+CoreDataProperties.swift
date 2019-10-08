//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

import CoreData
import Foundation

extension PayDay {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `PayDay` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PayDay> {
        return NSFetchRequest<PayDay>(entityName: "PayDay")
    }
    
    /// Raw value of the last pay day date. Use only in predicates (Optional)
    @NSManaged public var lastDateString: String?
    
    /// Raw value of the next pay day date. Use only in predicates (Optional)
    @NSManaged public var nextDateString: String?
    
    /// Raw value of the frequence. Use only in predicates
    @NSManaged public var periodRawValue: String
    
    /// Raw value of the status. Use only in predicates
    @NSManaged public var statusRawValue: String
    
}
