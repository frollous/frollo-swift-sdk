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
import SwiftyJSON

/**
 Card
 
 Core Data represenation of a Card
 */
public class Address: NSManagedObject, UniqueManagedObject {
    
    /// Core Data entity description name
    static var entityName = "Address"
    
    internal static var primaryKey = #keyPath(Address.addressID)
    
    internal var primaryID: Int64 {
        return addressID
    }
    
    internal func isValid() -> Bool {
        guard let postcode = postcode else {
            return false
        }
        return !postcode.isEmpty
    }
    
    // MARK: Updating Object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let cardsResponse = response as? APIAddressResponse {
            update(response: cardsResponse, context: context)
        }
    }
    
    internal func update(response: APIAddressResponse, context: NSManagedObjectContext) {
        addressID = response.id
        buildingName = response.buildingName
        unitNumber = response.unitNumber
        streetNumber = response.streetNumber
        streetName = response.streetName
        streetType = response.streetType
        suburb = response.suburb
        town = response.town
        region = response.region
        state = response.state
        country = response.country
        postcode = response.postcode
        longForm = response.longForm
    }
    
}
