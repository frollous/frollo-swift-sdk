//
//  Copyright © 2019 Frollo. All rights reserved.
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

import CoreData
import Foundation

extension BPAYContact {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `BPAYContact` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BPAYContact> {
        return NSFetchRequest<BPAYContact>(entityName: "BPAYContact")
    }
    
    /// Biller code of the BPAY contact
    @NSManaged public var billerCode: String
    
    /// CRN of the BPAY contact
    @NSManaged public var crn: String
    
    /// Biller name of the BPAY contact
    @NSManaged public var billerName: String
    
    /// The type of CRN; defaulted to fixed crn,
    @NSManaged public var crnTypeRawValue: String
}
