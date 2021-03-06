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

struct APIUserRegisterRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case clientID = "client_id"
        case dateOfBirth = "date_of_birth"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case mobileNumber = "mobile_number"
        case password
        
    }
    
    let clientID: String
    let email: String
    let firstName: String
    let password: String
    let dateOfBirth: Date?
    let lastName: String?
    let mobileNumber: String?
    
}
