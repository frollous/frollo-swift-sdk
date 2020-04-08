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
import SwiftyJSON

struct APICDRConsentResponse: Codable, APIUniqueResponse {
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerID = "provider_id"
        case providerAccountID = "provider_account_id"
        case sharingDuration = "sharing_duration"
        case permissions
        case additionalPermissions = "additional_permissions"
        case deleteRedundantData = "delete_redundant_data"
        case status
        case authorisationRequestURL = "authorisation_request_url"
        case confirmationPDFURL = "confirmation_pdf_url"
        case withdrawalPDFURL = "withdrawal_pdf_url"
        case sharingStartedAt = "sharing_started_at"
    }
    
    /// The id of the consent
    var id: Int64
    
    /// The id for the provider
    let providerID: Int64
    
    /// The provider id for the consent
    let providerAccountID: Int64
    
    /// Start date of the sharing window. This date is the date when the consent officially starts on the Data Holder's end.
    let sharingStartedAt: String?
    
    /// The duration (in seconds) for the consent
    let sharingDuration: Int64?
    
    /// The permissions requested for the consent
    let permissions: [String]
    
    /// Additional permissions that can be set
    let additionalPermissions: [String: Bool]?
    
    /// Specifies whether the data should be deleted after the consent is done
    let deleteRedundantData: Bool
    
    /// The status of the consent
    let status: String
    
    /// The authorization URL that should be used to initiate a login with the provider
    let authorisationRequestURL: String?
    
    /// URL of the Consent Confirmation PDF.
    let confirmationPDFURL: String?
    
    /// URL of the Consent Withdrawal PDF.
    let withdrawalPDFURL: String?
    
}
