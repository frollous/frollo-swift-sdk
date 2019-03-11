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

struct NotificationPayload: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case aps
        case event
        case link
        case transactionIDs = "transaction_ids"
        case userEventID = "user_event_id"
        case userMessageID = "user_message_id"
        
    }
    
    struct ApplePayload: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case alert
            case badge
            case category
            case contentAvailable = "content-available"
            case mutableContent = "mutable-content"
            case sound
            case threadID = "thread-id"
            
        }
        
        struct Alert: Codable {
            
            enum CodingKeys: String, CodingKey {
                
                case body
                case launchImage = "launch-image"
                case locArgs = "loc-args"
                case locKey = "loc-key"
                case subtitle
                case subtitleLocArgs = "subtitle-loc-args"
                case subtitleLocKey = "subtitle-loc-key"
                case title
                case titleLocArgs = "title-loc-args"
                case titleLocKey = "title-loc-key"
                
            }
            
            let body: String?
            let launchImage: String?
            let locArgs: [String]?
            let locKey: String?
            let subtitle: String?
            let subtitleLocArgs: [String]
            let subtitleLocKey: String?
            let title: String?
            let titleLocArgs: [String]?
            let titleLocKey: String?
            
        }
        
        struct Sound: Codable {
            
            let critical: Int?
            let name: String?
            let volume: Double?
            
        }
        
        let alert: Alert?
        let badge: Int?
        let category: String?
        let contentAvailable: Int?
        let mutableContent: Int?
        let sound: Sound?
        let threadID: String?
        
    }
    
    let aps: ApplePayload?
    let event: String?
    let link: String?
    let transactionIDs: [Int64]?
    let userEventID: Int64?
    let userMessageID: Int64?
    
}
