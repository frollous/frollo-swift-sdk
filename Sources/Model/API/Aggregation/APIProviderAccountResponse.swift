//
//  APIProviderAccountResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIProviderAccountResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case editable
        case id
        case providerID = "provider_id"
        case refreshStatus = "refresh_status"
    }
    
    struct RefreshStatus: Codable {
        
        enum CodingKeys: String, CodingKey {
            case additionalStatus = "additional_status"
            case lastRefreshed = "last_refreshed"
            case nextRefresh = "next_refresh"
            case status
            case subStatus = "sub_status"
        }
        
        let status: AccountRefreshStatus
        
        var additionalStatus: AccountRefreshAdditionalStatus?
        var lastRefreshed: Date?
        var nextRefresh: Date?
        var subStatus: AccountRefreshSubStatus?
    }
    
    var id: Int64
    let editable: Bool
    let providerID: Int64
    let refreshStatus: RefreshStatus
    
}
