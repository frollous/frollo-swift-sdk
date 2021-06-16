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

extension Consent: TestableCoreData {
    
    func populateTestData() {
        consentID = Int64.random(in: 1...Int64.max)
        additionalPermissions = nil
        status = .active
        sharingDuration = Int64.random(in: 1...Int64.max)
        sharingStartedAtRawValue = "2020-01-03"
        sharingStoppedAtRawValue = "2020-05-03"
        authorizationURLString = "https://example.com/authorize"
        confirmationPDFURLString = "https://example.com/confirmation.pdf"
        withdrawalPDFURLString = "https://example.com/withdraw"
        permissionIDs = ["account_details", "transaction_details"]
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        consentID = id
    }
    
}
