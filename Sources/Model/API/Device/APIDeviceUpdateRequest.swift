//
//  APIDeviceUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIDeviceUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case compliant
        case deviceID = "device_id"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case notificationToken = "notification_token"
        case timezone
        
    }
    
    let compliant: Bool?
    let deviceID: String?
    let deviceName: String?
    let deviceType: String?
    let notificationToken: String?
    let timezone: String?
    
}
