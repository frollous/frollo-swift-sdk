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

extension Contact: TestableCoreData {
    
    @objc func populateTestData() {
        contactID = Int64.random(in: 1...Int64.max)
        name = String.randomString(range: 5...20)
        nickName = String.randomString(range: 5...20)
        contactDescription = String.randomString(range: 5...20)
        contactType = ContactType.allCases.randomElement()!
        createdDateString = "2020-12-04T11:36:42.648+11:00"
        modifiedDateString = "2020-12-04T11:36:42.648+11:00"
        associatedProviderAccountIDs = [Int64.random(in: 1...Int64.max)]
        isVerified = Bool.random()
    }
    
}
