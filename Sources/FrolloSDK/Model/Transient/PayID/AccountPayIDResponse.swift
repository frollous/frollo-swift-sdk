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
 PayID Response for an Account
 
 Represents a PayID associated with an account
 */

public struct AccountPayIDResponse: Codable {
    
    /// Status of the PayID
    public enum PayIDStatus: String, Codable, CaseIterable {
        /// PayID is Active
        case active = "ACTIVE"
        /// PayID is Portable
        case portable = "PORTABLE"
        /// PayID is Deregistered
        case deregistered = "DEREGISTERED"
        /// PayID is Disabled
        case disabled = "DISABLED"
    }
    
    enum CodingKeys: String, CodingKey {
        case payID = "payid"
        case status = "payid_status"
        case type
        case name = "payid_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    /// The value of the payId
    public var payID: String
    
    /// Current status of the PayID
    public var status: PayIDStatus
    
    /// The creditor PayID identifier type.
    public var type: PayIDContact.PayIDType
    
    /// The name of the payID; shown to external parties
    public var name: String
    
    /// The date and time the payID was registered
    public var createdAt: String?
    
    /// The date and time the payID was updated
    public var updatedAt: String?
}
