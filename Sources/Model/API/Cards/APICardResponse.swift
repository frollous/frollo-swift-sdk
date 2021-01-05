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

struct APICardResponse: Codable {
    
    /**
     Card Status
     
     Status indicating the current state of the card.
     */
    enum CardStatus: String, Codable, CaseIterable {
        /// The card is active
        case active
        
        /// The card is pending activation
        case pending
        
        /// The card is locked/ frozen
        case locked
    }
    
    /**
     Card Design Type
     
     Type indicating the design of the card
     */
    enum CardDesignType: String, Codable, CaseIterable {
        /// Default design
        case `default`
    }
    
    enum CodingKeys: String, CodingKey {
        case cardID = "id"
        case accountID = "account_id"
        case status
        case designType = "design_type"
        case createdAtDateString = "created_at"
        case name
        case nickName = "nick_name"
    }
    
    let cardID: Int64
    let accountID: Int64
    let status: CardStatus
    let designType: CardDesignType
    let createdAtDateString: String
    let name: String
    let nickName: String?
}
