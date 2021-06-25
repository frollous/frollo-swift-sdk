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

import Foundation
@testable import FrolloSDK

extension APIUserRegisterRequest {
    
    static func testData() -> APIUserRegisterRequest {
        return APIUserRegisterRequest(clientID: String.randomString(length: 32),
                                      email: String.randomString(range: 1...10) + "@frollo.us",
                                      firstName: String.randomString(range: 1...20),
                                      password: String.randomString(range: 1...20),
                                      dateOfBirth: Date(timeIntervalSince1970: 631152000),
                                      lastName: String.randomString(range: 1...20),
                                      mobileNumber: "0412345678")
    }
    
}
