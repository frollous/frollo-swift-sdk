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

struct APIMessageResponse: APIUniqueResponse {
    
    enum CodingKeys: String, CodingKey {
        
        case action
        case content
        case contentType = "content_type"
        case event
        case footer
        case header
        case iconURL = "icon_url"
        case id
        case interacted
        case messageTypes = "message_types"
        case persists
        case placement
        case read
        case title
        case userEventID = "user_event_id"
        case autoDismiss = "auto_dismiss"
        
    }
    
    enum Content: Equatable {
        
        struct HTML: Codable, Equatable {
            
            enum CodingKeys: String, CodingKey {
                case footer
                case header
                case main
            }
            
            let footer: String?
            let header: String?
            let main: String
            
        }
        
        struct Image: Codable, Equatable {
            
            let height: Double
            let url: String
            let width: Double
            
        }
        
        struct Text: Codable, Equatable {
            
            enum CodingKeys: String, CodingKey {
                case designType = "design_type"
                case footer
                case header
                case imageURL = "image_url"
                case text
            }
            
            let designType: String
            let footer: String?
            let header: String?
            let imageURL: String?
            let text: String?
            
        }
        
        struct Video: Codable, Equatable {
            
            enum CodingKeys: String, CodingKey {
                case autoplay
                case autoplayCellular = "autoplay_cellular"
                case height
                case iconURL = "icon_url"
                case muted
                case url
                case width
            }
            
            let autoplay: Bool
            let autoplayCellular: Bool
            let height: Double?
            let iconURL: String?
            let muted: Bool
            let url: String
            let width: Double?
            
        }
        
        case html(HTML)
        case image(Image)
        case text(Text)
        case video(Video)
        
        static func == (lhs: APIMessageResponse.Content, rhs: APIMessageResponse.Content) -> Bool {
            switch (lhs, rhs) {
                case (let .html(lhsPayload), .html(let rhsPayload)):
                    return lhsPayload == rhsPayload
                case (let .image(lhsPayload), .image(let rhsPayload)):
                    return lhsPayload == rhsPayload
                case (let .text(lhsPayload), .text(let rhsPayload)):
                    return lhsPayload == rhsPayload
                case (let .video(lhsPayload), .video(let rhsPayload)):
                    return lhsPayload == rhsPayload
                default:
                    return false
            }
        }
        
    }
    
    struct Link: Codable {
        
        enum CodingKeys: String, CodingKey {
            case link
            case openExternal = "open_external"
            case title
        }
        
        let link: String?
        let openExternal: Bool
        let title: String?
        
    }
    
    var id: Int64
    let action: Link?
    let content: Content?
    let contentType: Message.ContentType
    let event: String
    let interacted: Bool
    let messageTypes: [String]
    let persists: Bool
    let placement: Int64
    let read: Bool
    let title: String?
    let userEventID: Int64?
    let autoDismiss: Bool
    
}

extension APIMessageResponse: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        action = try container.decodeIfPresent(Link.self, forKey: .action)
        contentType = try container.decode(Message.ContentType.self, forKey: .contentType)
        event = try container.decode(String.self, forKey: .event)
        interacted = try container.decode(Bool.self, forKey: .interacted)
        messageTypes = try container.decode([String].self, forKey: .messageTypes)
        persists = try container.decode(Bool.self, forKey: .persists)
        placement = try container.decode(Int64.self, forKey: .placement)
        read = try container.decode(Bool.self, forKey: .read)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userEventID = try container.decodeIfPresent(Int64.self, forKey: .userEventID)
        autoDismiss = try container.decode(Bool.self, forKey: .autoDismiss)
        
        switch contentType {
            case .html:
                let contents = try container.decode(Content.HTML.self, forKey: .content)
                self.content = .html(contents)
                
            case .image:
                let contents = try container.decode(Content.Image.self, forKey: .content)
                self.content = .image(contents)
                
            case .text:
                let contents = try container.decode(Content.Text.self, forKey: .content)
                self.content = .text(contents)
                
            case .video:
                let contents = try container.decode(Content.Video.self, forKey: .content)
                content = .video(contents)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(action, forKey: .action)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(event, forKey: .event)
        try container.encode(interacted, forKey: .interacted)
        try container.encode(messageTypes, forKey: .messageTypes)
        try container.encode(persists, forKey: .persists)
        try container.encode(placement, forKey: .placement)
        try container.encode(read, forKey: .read)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(userEventID, forKey: .userEventID)
        
        if let contents = content {
            switch contents {
                case .html(let payload):
                    try container.encode(payload, forKey: .content)
                    
                case .image(let payload):
                    try container.encode(payload, forKey: .content)
                    
                case .text(let payload):
                    try container.encode(payload, forKey: .content)
                    
                case .video(let payload):
                    try container.encode(payload, forKey: .content)
                    
            }
        }
    }
    
}
