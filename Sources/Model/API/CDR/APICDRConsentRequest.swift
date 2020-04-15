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

struct APICDRConsentCreateRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case providerID = "provider_id"
        case sharingDuration = "sharing_duration"
        case permissions
        case additionalPermissions = "additional_permissions"
        case deleteRedundantData = "delete_redundant_data"
    }
    
    /// The id for the provider
    let providerID: Int64
    
    /// The duration (in seconds) for the consent
    let sharingDuration: TimeInterval
    
    /// The permissions requested for the consent
    let permissions: [String]
    
    /// Additional permissions (meta-data) that can be set
    let additionalPermissions: [String: Bool]
    
    /// Specifies whether the data should be deleted after the consent is done
    let deleteRedundantData: Bool
}

struct APICDRConsentUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case deleteRedundantData = "delete_redundant_data"
        case sharingDuration = "sharing_duration"
        case status
    }
    
    /// The new status for the consent
    public let status: Consent.Status?
    
    /// The new value for the delete redundant data (Optional)
    public let deleteRedundantData: Bool?
    
    /// The new value for duration (in seconds) for the consent (Optional)
    public let sharingDuration: TimeInterval?
    
    /** Initialize a CDR Consent form to send to the host
     
     - parameters:
         - status: The new status for the consent
         - sharingDuration: The new sharingDuration for the consent
     */
    public init(status: Consent.Status? = nil, sharingDuration: TimeInterval? = nil) {
        self.status = status
        self.deleteRedundantData = true
        self.sharingDuration = sharingDuration
    }
    
}
