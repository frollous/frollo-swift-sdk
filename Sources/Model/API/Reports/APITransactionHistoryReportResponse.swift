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

public struct APIReportsResponse: Codable {
    
    public struct Report: Codable {
        
        public struct GroupReport: Codable {
            
            enum CodingKeys: String, CodingKey {
                case income
                case id
                case name
                case transactionIDs = "transaction_ids"
                case value
            }
            
            public let income: Bool
            public let id: Int64
            public let name: String
            public let transactionIDs: [Int64]
            public let value: String
            
        }
        
        public let groups: [GroupReport]
        public let income: Bool
        public let date: String
        public let value: String
        
    }
    
    public let data: [Report]
    
}
