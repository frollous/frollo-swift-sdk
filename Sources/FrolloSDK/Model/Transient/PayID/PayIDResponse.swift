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
 PayID Response
 
 Represents a PayID for the User
 */
public struct PayIDResponse: Codable {
    
    /// Status of the PayID
    public enum PayIDStatus: String, Codable, CaseIterable {
        /// PayID is available for registration
        
        case available
        /// PayID is already registered
        case registered
        
        /// PayID details are not confirmed
        case unconfirmed
        
        /// Undetermined
        case unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case payID = "id"
        case status
        case type
    }
    
    /// The value of the payId
    public var payID: String
    /// Status of the PayID
    public var status: PayIDStatus
    /// Type of the PayID
    public var type: PayIDContact.PayIDType
}
