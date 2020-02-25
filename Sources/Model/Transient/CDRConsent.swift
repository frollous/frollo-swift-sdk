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

/**
 Consent form that can be submit to create a consent with a provider
 */
public struct CDRConsentForm: Codable {
    
    public struct Post {
        
        /// The ID for the provider
        public let providerID: Int64
        
        /// The duration (in seconds) for the consent
        public let sharingDuration: TimeInterval
        
        /// The permissions requested for the consent
        public let permissions: [Provider.Permission]
        
        /// Additional permissions (metadata) that can be set
        public let additionalPermissions: [String: Bool]
        
        /// Specifies whether the data should be deleted after the consent is done
        public let deleteRedundantData: Bool
        
        /** Initialize a CDR Consent form to send to the host
         
         - parameters:
             - provider: ID of the provider to submit consent for
             - sharingDuration: The duration (in seconds) for the consent
             - permissions: The permissions requested for the consent
             - additionalPermissions: Additional permissions (metadata) that can be set
             - deleteRedundantData: Specifies whether the data should be deleted after the consent is done
         
         - returns: A CDR Consent form ready to send to the host
         */
        public init(providerID: Int64, sharingDuration: TimeInterval, permissions: [Provider.Permission], additionalPermissions: [String: Bool] = [:], deleteRedundantData: Bool) {
            self.providerID = providerID
            self.sharingDuration = sharingDuration
            self.permissions = permissions
            self.additionalPermissions = additionalPermissions
            self.deleteRedundantData = deleteRedundantData
        }
    }
    
    public struct Put {
        
        /// The new status for the consent
        public let status: CDRConsent.Status
        
        /// The new value for the delete redundant data
        public let deleteRedundantData: Bool
        
        /** Initialize a CDR Consent form to send to the host
         
         - parameters:
             - status: The new status for the consent
             - deleteRedundantData: The new value for the delete redundant data
         */
        public init(status: CDRConsent.Status, deleteRedundantData: Bool) {
            self.status = status
            self.deleteRedundantData = deleteRedundantData
        }
    }
}

extension CDRConsentForm.Post {
    
    /// Creates an APICDRConsentRequest from the form
    var apiRequest: APICDRConsentCreateRequest {
        return APICDRConsentCreateRequest(providerID: providerID, sharingDuration: sharingDuration, permissions: permissions.map { $0.rawValue }, additionalPermissions: additionalPermissions, deleteRedundantData: deleteRedundantData)
    }
}

/**
 Represents the details of a submitted consent
 */
public struct CDRConsent: Codable {
    
    /**
     Consent Status
     
     The status of the provider's consent
     */
    public enum Status: String, Codable {
        
        /// The consent is still pending
        case pending
        
        /// The consent is now active
        case active
        
        /// The consent has been withdrawn
        case withdrawn
        
        /// The consent has been expired
        case expired
    }
    
    /// The id for the provider
    public let providerID: Int64
    
    /// Start date of the sharing window. This date is the date when the consent officially starts on the Data Holder's end.
    public let sharingStartedAt: Date?
    
    /// The duration (in seconds) for the consent
    public let sharingDuration: Int32
    
    /// The permissions requested for the consent
    public let permissions: [Provider.Permission]
    
    /// Additional permissions (meta-data) that can be set
    public let additionalPermissions: [String: Bool]?
    
    /// Specifies whether the data should be deleted after the consent is done
    public let deleteRedundantData: Bool
    
    /// The status of the consent
    public let status: Status
    
    /// The authorization URL that should be used to initiate a login with the provider
    public let authorisationRequestURL: URL?
    
    /// URL of the Consent Confirmation PDF.
    public let confirmationPDFURL: URL
    
    /// URL of the Consent Withdrawal PDF.
    public let withdrawalPDFURL: URL?
}

extension APICDRConsentResponse {
    
    /// Creates a public consent object from the API response
    var consent: CDRConsent {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return .init(providerID: providerID,
                     sharingStartedAt: dateFormatter.date(from: sharingStartedAt ?? ""),
                     sharingDuration: sharingDuration,
                     permissions: permissions.map { Provider.Permission(rawValue: $0) }.compactMap { $0 },
                     additionalPermissions: additionalPermissions,
                     deleteRedundantData: deleteRedundantData,
                     status: CDRConsent.Status(rawValue: status) ?? .pending,
                     authorisationRequestURL: URL(string: authorisationRequestURL ?? ""),
                     confirmationPDFURL: URL(string: confirmationPDFURL)!,
                     withdrawalPDFURL: URL(string: withdrawalPDFURL ?? ""))
    }
}
