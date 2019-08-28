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

struct APIProviderAccountResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case editable
        case externalID = "external_id"
        case id
        case loginForm = "login_form"
        case providerID = "provider_id"
        case refreshStatus = "refresh_status"
    }
    
    struct RefreshStatus: Codable {
        
        enum CodingKeys: String, CodingKey {
            case additionalStatus = "additional_status"
            case lastRefreshed = "last_refreshed"
            case nextRefresh = "next_refresh"
            case status
            case subStatus = "sub_status"
        }
        
        let status: AccountRefreshStatus
        
        var additionalStatus: AccountRefreshAdditionalStatus?
        var lastRefreshed: Date?
        var nextRefresh: Date?
        var subStatus: AccountRefreshSubStatus?
    }
    
    var id: Int64
    let editable: Bool
    let externalID: String?
    let loginForm: ProviderLoginForm?
    let providerID: Int64
    let refreshStatus: RefreshStatus
    
}
