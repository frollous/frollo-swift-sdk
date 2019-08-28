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

extension APIProviderAccountResponse {
    
    static func testCompleteDate() -> APIProviderAccountResponse {
        let refreshStatus = RefreshStatus(status: .needsAction,
                                          additionalStatus: .mfaNeeded,
                                          lastRefreshed: Date(timeIntervalSince1970: 1533183204),
                                          nextRefresh: Date(timeIntervalSince1970: 1533183224),
                                          subStatus: .inputRequired)
        
        return APIProviderAccountResponse(id: 76251,
                                          editable: true,
                                          externalID: UUID().uuidString,
                                          loginForm: ProviderLoginForm.loginFormFilledData(),
                                          providerID: 54321,
                                          refreshStatus: refreshStatus)
    }
    
}
