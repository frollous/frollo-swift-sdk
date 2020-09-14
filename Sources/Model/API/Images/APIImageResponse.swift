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

struct APIImageResponse: APIUniqueResponse {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case imageTypes = "image_type"
        case smallImageURL = "small_image_url"
        case largeImageURL = "large_image_url"
        
    }
    
    var id: Int64
    let name: String
    let imageTypes: [String]
    let smallImageURL: String
    let largeImageURL: String
    
}
