//
//  APILogRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 29/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APILogRequest: Codable {
    
    let details: String?
    let deviceID: String
    let deviceName: String
    let deviceType: String
    let message: String
    let score: LogLevel
    
}
