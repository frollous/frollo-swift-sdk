//
//  APIAccountUpdateRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIAccountUpdateRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case favourite
        case hidden
        case included
        case nickName = "nick_name"
    }
    
    let favourite: Bool
    let hidden: Bool
    let included: Bool
    
    var nickName: String?
    
    var valid: Bool {
        get {
            return !(hidden && included)
        }
    }
    
}
