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
 ManagedProduct Model
 
 Holds information about Managed Product
 */
public class ManagedProduct: Codable {
    
    /// unique ID of `ManagedProduct`
    public var id: Int64
    
    /// name of`ManagedProduct`
    public var name: String
    
    /// ID of Provider to which `ManagedProduct` belongs
    public var providerID: Int64
    
    /// container of `ManagedProduct`
    public var container: String
    
    /// account type of `ManagedProduct`
    public var accountType: String
    
    /// Array of terms and conditions for the `ManagedProduct`
    public var termsConditions: [TermsCondition]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case providerID = "provider_id"
        case container
        case accountType = "account_type"
        case termsConditions = "terms_conditions"
    }
    
    // Initiliser
    init(id: Int64, name: String, providerID: Int64, container: String, accountType: String, termsConditions: [TermsCondition]) {
        self.id = id
        self.name = name
        self.providerID = providerID
        self.container = container
        self.accountType = accountType
        self.termsConditions = termsConditions
    }
    
    /**
     Terms Condition
     
     Object to hold information of `TermsCondition`
     */
    public class TermsCondition: Codable {
        
        /// Name of `TermsCondition`
        public var name: String
        
        /// URL of `TermsCondition`
        public var url: String?
        
        private enum CodingKeys: String, CodingKey {
            case name
            case url
        }
        
    }
    
}
