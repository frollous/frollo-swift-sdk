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
        case accountType = "account_type"
        case favourite
        case hidden
        case included
        case nickName = "nick_name"
    }
    
    let accountType: Account.AccountSubType?
    let favourite: Bool?
    let hidden: Bool
    let included: Bool
    let nickName: String?
    
    var valid: Bool {
        get {
            return !(hidden && included)
        }
    }
    
}
