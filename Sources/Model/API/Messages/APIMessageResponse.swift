//
//  APIMessageResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIMessageResponse: APIUniqueResponse {
    
    enum CodingKeys: String, CodingKey {
        
        case action
        case button
        case clicked
        case content
        case contentType = "content_type"
        case designType = "design_type"
        case event
        case footer
        case header
        case iconURL = "icon_url"
        case id
        case messageTypes = "message_types"
        case persists
        case placement
        case read
        case title
        case userEventID = "user_event_id"
        
    }
    
    enum Content: Equatable {
        
        struct HTML: Codable, Equatable {
            
            enum CodingKeys: String, CodingKey {
                case body
            }
            
            let body: String
            
        }
        
        struct Image: Codable, Equatable {
            
            let height: Double
            let url: String
            let width: Double
            
        }
        
        struct Text: Codable, Equatable {
            
            enum CodingKeys: String, CodingKey {
                case body
            }
            
            let body: String
            
        }
        
        struct Video: Codable, Equatable {
            
            enum CodingKeys: String, CodingKey {
                case autoplay
                case autoplayCellular = "autoplay_cellular"
                case height
                case muted
                case url
                case width
            }
            
            let autoplay: Bool
            let autoplayCellular: Bool
            let height: Double?
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
                case (let .html(lhsPayload), let .html(rhsPayload)):
                    return lhsPayload == rhsPayload
                case (let .image(lhsPayload), let .image(rhsPayload)):
                    return lhsPayload == rhsPayload
                case (let .text(lhsPayload), let .text(rhsPayload)):
                    return lhsPayload == rhsPayload
                case (let .video(lhsPayload), let .video(rhsPayload)):
                    return lhsPayload == rhsPayload
                default:
                    return false
            }
        }
        
    }
    
    enum MessageType: String, Codable {
        
        case creditScore = "credit_score"
        case feed
        case goalNudge = "goal_nudge"
        case homeNudge = "home_nudge"
        case popup
        case setupNudge = "setup_nudge"
        case welcomeNudge = "welcome_nudge"
        
    }
    
    struct Link: Codable {
        
        enum CodingKeys: String, CodingKey {
            case link
            case openExternal = "open_external"
            case title = "title"
        }
        
        let link: String?
        let openExternal: Bool
        let title: String?
        
    }
    
    var id: Int64
    let action: Link?
    let button: Link?
    let clicked: Bool
    let content: Content?
    let contentType: Message.ContentType
    let designType: Message.Design
    let footer: String?
    let header: String?
    let event: String
    let iconURL: String?
    let messageTypes: [MessageType]
    let persists: Bool
    let placement: Int64
    let read: Bool
    let title: String?
    let userEventID: Int64?
    
}

extension APIMessageResponse: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
        action = try container.decodeIfPresent(Link.self, forKey: .action)
        button = try container.decodeIfPresent(Link.self, forKey: .button)
        clicked = try container.decode(Bool.self, forKey: .clicked)
        contentType = try container.decode(Message.ContentType.self, forKey: .contentType)
        designType = try container.decode(Message.Design.self, forKey: .designType)
        footer = try container.decodeIfPresent(String.self, forKey: .footer)
        header = try container.decodeIfPresent(String.self, forKey: .header)
        event = try container.decode(String.self, forKey: .event)
        iconURL = try container.decodeIfPresent(String.self, forKey: .iconURL)
        messageTypes = try container.decode([MessageType].self, forKey: .messageTypes)
        persists = try container.decode(Bool.self, forKey: .persists)
        placement = try container.decode(Int64.self, forKey: .placement)
        read = try container.decode(Bool.self, forKey: .read)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userEventID = try container.decodeIfPresent(Int64.self, forKey: .userEventID)
        
        switch contentType {
            case .html5:
                let contents = try container.decode(Content.HTML.self, forKey: .content)
                self.content = .html(contents)
            
            case .textAndImage:
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
        try container.encodeIfPresent(button, forKey: .button)
        try container.encode(clicked, forKey: .clicked)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(designType, forKey: .designType)
        try container.encodeIfPresent(footer, forKey: .footer)
        try container.encodeIfPresent(header, forKey: .header)
        try container.encode(event, forKey: .event)
        try container.encodeIfPresent(iconURL, forKey: .iconURL)
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
