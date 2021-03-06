//
// Copyright © 2018 Frollo. All rights reserved.
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

struct APIDeviceLogRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case details
        case deviceID = "device_id"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case message
        case score
        
    }
    
    let details: String?
    let deviceID: String
    let deviceName: String
    let deviceType: String
    let message: String
    let score: LogLevel
    
}
