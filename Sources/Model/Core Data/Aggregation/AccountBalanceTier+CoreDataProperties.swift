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

extension AccountBalanceTier {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `AccountBalanceTier` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountBalanceTier> {
        return NSFetchRequest<AccountBalanceTier>(entityName: "AccountBalanceTier")
    }
    
    /// Maximum balance value included in this tier (optional)
    @NSManaged public var maximum: NSDecimalNumber?
    
    /// Minimum balance value included in this tier (optional)
    @NSManaged public var minimum: NSDecimalNumber?
    
    /// Name of this tier (optional)
    @NSManaged public var name: String?
    
    /// Parent account
    @NSManaged public var account: Account?
    
}
