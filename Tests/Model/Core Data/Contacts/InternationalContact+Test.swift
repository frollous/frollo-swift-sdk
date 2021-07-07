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

extension InternationalContact {
    
    override func populateTestData() {
        super.populateTestData()

        internationalContactName = String.randomString(range: 5...20)
        internationalContactCountry = String.randomString(range: 5...20)
        internationalContactMessage = String.randomString(range: 5...20)
        internationalBankCountry = String.randomString(range: 5...20)
        internationalAccountNumber = String(Int.random(in: 1000000...Int.max))
        internationalBankAddress = String.randomString(range: 5...20)
        bic = String.randomString(range: 5...20)
        fedwireNumber = String.randomString(range: 5...20)
        sortCode = String.randomString(range: 5...20)
        chipNumber = String.randomString(range: 5...20)
        routingNumber = String.randomString(range: 5...20)
        legalEntityId = String.randomString(range: 5...20)
    }
    
}
