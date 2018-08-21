//
//  APIProviderAccountResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIProviderAccountResponse {
    
    static func testCompleteDate() -> APIProviderAccountResponse {
        let refreshStatus = RefreshStatus(status: .needsAction,
                                          additionalStatus: .mfaNeeded,
                                          lastRefreshed: Date(timeIntervalSince1970: 1533183204),
                                          nextRefresh: Date(timeIntervalSince1970: 1533183224),
                                          subStatus: .inputRequired)
        
        return APIProviderAccountResponse(id: 76251,
                                          editable: true,
                                          loginForm: nil,
                                          providerID: 54321,
                                          refreshStatus: refreshStatus)
    }
    
}
