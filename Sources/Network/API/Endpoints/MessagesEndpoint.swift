//
//  MessagesEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

internal enum MessagesEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    case message(messageID: Int64)
    case messages
    case unread
    
    private func urlPath() -> String {
        switch self {
            case .message(let messageID):
                return "messages/" + String(messageID)
            case .messages:
                return "messages"
            case .unread:
                return "messages/unread"
        }
    }
    
}
