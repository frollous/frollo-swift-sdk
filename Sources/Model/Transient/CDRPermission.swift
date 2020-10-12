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

/// Represent a CDR permission (Ex: Transaction Details)
public struct CDRPermission: Codable {
    
    /// Represents 1 detail for the permission (Ex: Description of transactions)
    public struct Detail: Codable {
        
        /// The ID of the detail
        public let id: String
        
        /// The description for the detail
        public let description: String
    }
    
    /// The ID of the permission
    public let id: String
    
    /// The title of the permission
    public let title: String
    
    /// The description of the permission
    public let description: String
    
    /// Specifies whether this permission is required or not
    public let required: Bool
    
    /// The details of the permission
    public let details: [Detail]
}
