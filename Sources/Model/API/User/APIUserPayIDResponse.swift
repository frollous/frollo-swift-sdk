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

/// API User PayID Response
public struct APIUserPayIDResponse: Codable {
    
    public enum PayIDStatus: String, Codable, CaseIterable {
        case available
        case registered
        case unconfirmed
        case unknown
    }
    
    public enum PayIDType: String, Codable, CaseIterable {
        case email
        case mobile
    }
    
    enum CodingKeys: String, CodingKey {
        case payID = "id"
        case status
        case type
    }
    
    public var payID: String
    public var status: PayIDStatus
    public var type: PayIDType
}
