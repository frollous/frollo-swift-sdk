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

import XCTest
@testable import FrolloSDK

class AddressAutocompleteTest: XCTestCase {


}

extension APIAddressAutocompleteResopnse {
    
    static func getTestAddress() -> APIAddressAutocompleteResopnse{
        return APIAddressAutocompleteResopnse(buildingName: "100 Mount", unitNumber: "Unit 3", streetNumber: "100", streetName: "Mount", streetType: "street", suburb: "North Sydney", town: "Sydney", region: "Greater Sydney", state: "NSW", country: "AU", postcode: "2060", longForm: "Frollo, Level 33, 100 Mount St, North Sydney, NSW, 2060, Australia")
    }
    
}
