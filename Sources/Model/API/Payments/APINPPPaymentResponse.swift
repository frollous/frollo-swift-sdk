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

struct APINPPPaymentResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "transaction_id"
        case isDuplicate = "is_duplicate"
        case description
    }
    
    let transactionID: String
    
    let isDuplicate: Bool
    
    let description: String?
    
}
