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

extension APIAccountUpdateRequest {
    
    static func testUpdateDataValid() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(accountType: Account.AccountSubType.allCases.randomElement(),
                                       favourite: Bool.random(),
                                       hidden: false,
                                       included: false,
                                       nickName: String.randomString(range: 2...50),
                                       productID: -1)
    }
    
    static func testUpdateDataInvalid() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(accountType: .bankAccount,
                                       favourite: false,
                                       hidden: true,
                                       included: true,
                                       nickName: "My Invalid Account",
                                       productID: nil)
    }
    
}
