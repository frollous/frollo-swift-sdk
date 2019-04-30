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

extension Tag: TestableCoreData {
    
    func populateTestData() {
        name = String.randomString(range: 1...10)
        count = Int64.random(in: 1...Int64.max)
        lastUsedAt = Date(timeIntervalSinceNow: Double.random(in: 1...100000))
        createdAt = Date(timeIntervalSinceNow: Double.random(in: 1...100000))
    }
    
    func populateTestData(withName name: String) {
        populateTestData()
        
        self.name = name
    }
    
}
