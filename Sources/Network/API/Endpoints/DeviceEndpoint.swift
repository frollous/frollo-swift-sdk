//
//  DeviceEndpoint.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

enum DeviceEndpoint: Endpoint {
    
    internal var path: String {
        get {
            return urlPath()
        }
    }
    
    case device
    case devices
    case log
    
    private func urlPath() -> String {
        switch self {
            case .device:
                return "device"
            case .devices:
                return"devices"
            case .log:
                return "device/log"
        }
    }
    
}
