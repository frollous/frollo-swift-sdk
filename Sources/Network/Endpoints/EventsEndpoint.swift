//
//  EventsEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum EventsEndpoint: Endpoint {
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case events
    
    private func urlPath() -> String {
        switch self {
            case .events:
                return "events"
        }
    }
    
}
