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

extension APIAddressResponse {
    
    static func testCompleteData() -> APIAddressResponse {
        
        return APIAddressResponse(id: Int64.random(in: Int64.min...Int64.max), buildingName: String(Int64.random(in: Int64.min...Int64.max)), unitNumber: String(Int64.random(in: Int64.min...Int64.max)), streetNumber: String(Int64.random(in: Int64.min...Int64.max)), streetName: String(Int64.random(in: Int64.min...Int64.max)), streetType: String(Int64.random(in: Int64.min...Int64.max)), suburb: String(Int64.random(in: Int64.min...Int64.max)), town: String(Int64.random(in: Int64.min...Int64.max)), region: String(Int64.random(in: Int64.min...Int64.max)), state: String(Int64.random(in: Int64.min...Int64.max)), country: String(Int64.random(in: Int64.min...Int64.max)), postcode: String(Int64.random(in: Int64.min...Int64.max)), longForm: String(Int64.random(in: Int64.min...Int64.max)))
    }
    
}
