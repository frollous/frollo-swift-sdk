//
//  APIMessageUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIMessageUpdateRequest: Codable {
    
    let interacted: Bool
    let read: Bool
    
}
