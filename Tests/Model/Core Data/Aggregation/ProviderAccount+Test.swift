//
//  ProviderAccount+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension ProviderAccount: TestableCoreData {
    
    func populateTestData() {
        providerAccountID = Int64(arc4random())
        providerID = Int64(arc4random())
        editable = true
        lastRefreshed = Date(timeIntervalSince1970: 1533183204)
        nextRefresh = Date(timeIntervalSince1970: 1533183224)
        refreshStatus = .needsAction
        refreshSubStatus = .inputRequired
        refreshAdditionalStatus = .mfaNeeded
    }
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        providerAccountID = id
    }
    
}
