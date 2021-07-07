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

extension Address {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Address` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }
    
    /// Unique identifier of the address
    @NSManaged public var addressID: Int64
    
    /// Building name of the Address (optional)
    @NSManaged public var buildingName: String?
    
    /// Country of the Address in short form. eg: AUD
    @NSManaged public var country: String
    
    /// Long formatted name of the Address (optional)
    @NSManaged public var longForm: String?
    
    /// Postcode of the Address (optional)
    @NSManaged public var postcode: String?
    
    /// Region of the Address (optional)
    @NSManaged public var region: String?
    
    /// State of the Address (optional)
    @NSManaged public var state: String?
    
    /// Street name of the Address (optional)
    @NSManaged public var streetName: String?
    
    /// Street number of the Address (optional)
    @NSManaged public var streetNumber: String?
    
    /// Street type of the Address (optional)
    @NSManaged public var streetType: String?
    
    /// Suburb name of the Address (optional)
    @NSManaged public var suburb: String?
    
    /// Town name of the Address (optional)
    @NSManaged public var town: String?
    
    /// Unit number of the Address (optional)
    @NSManaged public var unitNumber: String?
    
}
