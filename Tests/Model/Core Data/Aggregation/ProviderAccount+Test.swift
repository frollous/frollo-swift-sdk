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

extension ProviderAccount: TestableCoreData {
    
    func populateTestData() {
        providerAccountID = Int64.random(in: 1...Int64.max)
        providerID = Int64.random(in: 1...Int64.max)
        editable = true
        lastRefreshed = Date(timeIntervalSince1970: 1533183204)
        nextRefresh = Date(timeIntervalSince1970: 1533183224)
        refreshStatus = .needsAction
        refreshSubStatus = .inputRequired
        refreshAdditionalStatus = .mfaNeeded
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        providerAccountID = id
    }
    
}
