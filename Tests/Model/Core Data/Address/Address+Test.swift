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

import Foundation
@testable import FrolloSDK
import XCTest

extension Address: TestableCoreData {
    
    func populateTestData() {
        addressID = Int64.random(in: 1...Int64.max)
        country = String.randomString(range: 5...20)
        longForm = String.randomString(range: 5...20)
        postcode = String.randomString(range: 5...20)
        region = String.randomString(range: 5...20)
        state = String.randomString(range: 5...20)
        streetName = String.randomString(range: 5...20)
        streetNumber = String.randomString(range: 5...20)
        streetType = String.randomString(range: 5...20)
        suburb = String.randomString(range: 5...20)
        town = String.randomString(range: 5...20)
        unitNumber = String.randomString(range: 5...20)
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        addressID = id
    }
    
    
}

class Addresstests: XCTestCase {
    
    func testUpdatingAddress() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            
            let addressResponse = APIAddressResponse.testCompleteData()
            
            let address = Address(context: managedObjectContext)
            address.update(response: addressResponse, context: managedObjectContext)
            
            XCTAssertEqual(address.addressID, addressResponse.id)
            XCTAssertEqual(address.buildingName, addressResponse.buildingName)
            XCTAssertEqual(address.unitNumber, addressResponse.unitNumber)
            XCTAssertEqual(address.streetName, addressResponse.streetName)
            XCTAssertEqual(address.streetType, addressResponse.streetType)
            XCTAssertEqual(address.streetNumber, addressResponse.streetNumber)
            XCTAssertEqual(address.suburb, addressResponse.suburb)
            XCTAssertEqual(address.town, addressResponse.town)
            XCTAssertEqual(address.region, addressResponse.region)
            XCTAssertEqual(address.country, addressResponse.country)
            XCTAssertEqual(address.postcode, addressResponse.postcode)
            XCTAssertEqual(address.longForm, addressResponse.longForm)
        }
    }
}
