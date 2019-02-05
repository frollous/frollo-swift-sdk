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
        case deviceName = "device_name"
        case notificationToken = "notification_token"
        case timezone
        
    }
    
    let compliant: Bool?
    let deviceName: String?
    let notificationToken: String?
    let timezone: String?
    
}
