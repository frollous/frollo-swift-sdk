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
    
    /// Represents the create request structure of the consent form
    public struct Post {
        
        /// The ID for the provider
        public let providerID: Int64
        
        /// The duration (in seconds) for the consent
        public let sharingDuration: Int64
        
        /// The permissions requested for the consent
        public let permissions: [String]
        
        /// Additional permissions (metadata) that can be set
        public let additionalPermissions: [String: Bool]
        
        /// ID of the consent being updated
        public let existingConsentID: Int64?
        
        /** Initialize a CDR Consent form to send to the host
         
         - parameters:
             - provider: ID of the provider to submit consent for
             - sharingDuration: The duration (in seconds) for the consent
             - permissions: The permissions requested for the consent
             - additionalPermissions: Additional permissions (metadata) that can be set
             - deleteRedundantData: Specifies whether the data should be deleted after the consent is done
             - existingConsentID: ID of the consent being updated
         
         - returns: A CDR Consent form ready to send to the host
         */
        public init(providerID: Int64, sharingDuration: Int64, permissions: [String], additionalPermissions: [String: Bool] = [:], existingConsentID: Int64?) {
            self.providerID = providerID
            self.sharingDuration = sharingDuration
            self.permissions = permissions
            self.additionalPermissions = additionalPermissions
            self.existingConsentID = existingConsentID
        }
    }
    
    /// Represents the update request structure of the consent form
    public struct Put {
        
        /// The allowed status values for PUT consent request
        public enum Status: String, Codable {
            
            /// The consent is withdrawn
            case withdrawn
        }
        
        /// The new status for the consent
        public let status: Put.Status?
        
        /// The new value for the delete redundant data (Optional)
        let deleteRedundantData: Bool?
        
        /// The new value for duration (in seconds) for the consent (Optional)
        let sharingDuration: Int64?
        
        /** Initialize a CDR Consent form to send to the host
         
         - parameters:
              - status: The new status for the consent
              - deleteRedundantData: The new value for the delete redundant data
              - sharingDuration: The new value for duration (in seconds) for the consent
         */
        public init(status: CDRConsentForm.Put.Status? = nil, deleteRedundantData: Bool? = true, sharingDuration: Int64? = nil) {
            self.status = status
            self.deleteRedundantData = deleteRedundantData
            self.sharingDuration = sharingDuration
        }
    }
}

extension CDRConsentForm.Post {
    
    /// Creates an APICDRConsentCreateRequest from the form
    var apiRequest: APICDRConsentCreateRequest {
        return APICDRConsentCreateRequest(providerID: providerID, sharingDuration: sharingDuration, permissions: permissions, additionalPermissions: additionalPermissions, deleteRedundantData: true, existingConsentID: existingConsentID)
    }
}

extension CDRConsentForm.Put {
    
    /// Creates an APICDRConsentUpdateRequest from the form
    var apiRequest: APICDRConsentUpdateRequest {
        return .init(status: status, deleteRedundantData: deleteRedundantData, sharingDuration: sharingDuration)
    }
}
