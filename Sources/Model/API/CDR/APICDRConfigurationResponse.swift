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
import SwiftyJSON

struct APICDRConfigurationResponse: Codable {
    
    struct SharingDuration: Codable {
        enum CodingKeys: String, CodingKey {
            case duration
            case description
            case imageURL = "image_url"
        }
        
        var duration: Int64
        var description: String
        var imageURL: String
    }
    
    enum CodingKeys: String, CodingKey {
        case supportEmail = "support_email"
        case adrID = "adr_id"
        case adrName = "adr_name"
        case sharingDuration = "sharing_duration"
    }
    
    var supportEmail: String
    var adrID: String
    var adrName: String
    var sharingDuration: [SharingDuration]
    
}
