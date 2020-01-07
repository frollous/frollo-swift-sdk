//
// Copyright © 2019 Frollo. All rights reserved.
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

/// API Group Report Response
public struct APIGroupReport: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        case income
        case id
        case name
        case transactionIDs = "transaction_ids"
        case value
    }
    
    /// API Income Property
    public let income: Bool
    
    /// API ID Property
    public let id: Int64
    
    /// API Name Property
    public let name: String
    
    /// API  Transaction IDs Property
    public let transactionIDs: [Int64]
    
    /// API Value Property
    public let value: Decimal
    
}

internal struct APIReportsResponse: Codable {
    
    internal struct Report: Codable {
        
        internal let groups: [APIGroupReport]
        internal let income: Bool
        internal let date: String
        internal let value: Decimal
        
    }
    
    internal let data: [Report]
    
}
