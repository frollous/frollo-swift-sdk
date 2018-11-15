//
//  APIEventCreateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIEventCreateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case delayMinutes = "delay_minutes"
        case event
        
    }
    
    let delayMinutes: Int64?
    let event: String
    
}
