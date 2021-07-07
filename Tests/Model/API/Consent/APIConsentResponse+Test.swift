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

extension APICDRConsentResponse {
    
    static func testCompleteData() -> APICDRConsentResponse {
        return APICDRConsentResponse(additionalPermissions: ["something": true],
                                     authorisationRequestURL: "https://example.com/api/v2/cdr/consents/351/auth",
                                     confirmationPDFURL: "https://example.com/api/v2/cdr/consents/351/pdfs/confirmation",
                                     deleteRedundantData: Bool.random(),
                                     id: Int64.random(in: 1...Int64.max),
                                     permissionIDs: ["account_details", "transaction_details"],
                                     providerAccountID: Int64.random(in: 1...Int64.max),
                                     providerID: Int64.random(in: 1...Int64.max),
                                     sharingStartedAt: "2020-01-02",
                                     sharingStoppedAt: "2020-05-23",
                                     sharingDuration: 15814800,
                                     status: "active",
                                     withdrawalPDFURL: "https://example.com/api/v2/cdr/consents/351/pdfs/withdraw")
    }
    
}
