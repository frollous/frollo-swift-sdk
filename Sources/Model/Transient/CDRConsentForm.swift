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
        public let sharingDuration: TimeInterval
        
        /// The permissions requested for the consent
        public let permissions: [String]
        
        /// Additional permissions (metadata) that can be set
        public let additionalPermissions: [String: Bool]
        
        /** Initialize a CDR Consent form to send to the host
         
         - parameters:
             - provider: ID of the provider to submit consent for
             - sharingDuration: The duration (in seconds) for the consent
             - permissions: The permissions requested for the consent
             - additionalPermissions: Additional permissions (metadata) that can be set
             - deleteRedundantData: Specifies whether the data should be deleted after the consent is done
         
         - returns: A CDR Consent form ready to send to the host
         */
        public init(providerID: Int64, sharingDuration: TimeInterval, permissions: [String], additionalPermissions: [String: Bool] = [:]) {
            self.providerID = providerID
            self.sharingDuration = sharingDuration
            self.permissions = permissions
            self.additionalPermissions = additionalPermissions
        }
    }
    
    /// Represents the update request structure of the consent form
    public struct Put {
        
        /// The new status for the consent
        public let status: Consent.Status
        
        /** Initialize a CDR Consent form to send to the host
         
         - parameters:
             - status: The new status for the consent
             - deleteRedundantData: The new value for the delete redundant data
         */
        public init(status: Consent.Status) {
            self.status = status
        }
    }
}

extension CDRConsentForm.Post {
    
    /// Creates an APICDRConsentRequest from the form
    var apiRequest: APICDRConsentCreateRequest {
        return APICDRConsentCreateRequest(providerID: providerID, sharingDuration: sharingDuration, permissions: permissions, additionalPermissions: additionalPermissions, deleteRedundantData: true)
    }
}
