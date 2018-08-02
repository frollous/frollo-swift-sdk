//
//  ProviderAccount+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ProviderAccount)
public class ProviderAccount: NSManagedObject, CacheableManagedObject {
    
    internal var primaryID: Int64 {
        get {
            return providerAccountID
        }
    }

    static let entityName = "ProviderAccount"
    
    public var refreshStatus: AccountRefreshStatus {
        get {
            return AccountRefreshStatus(rawValue: refreshStatusRawValue!)!
        }
        set {
            refreshStatusRawValue = newValue.rawValue
        }
    }
    
    public var refreshSubStatus: AccountRefreshSubStatus? {
        get {
            if let rawValue = refreshSubStatusRawValue {
                return AccountRefreshSubStatus(rawValue: rawValue)
            }
            return nil
        }
        set {
            refreshSubStatusRawValue = newValue?.rawValue
        }
    }
    
    public var refreshAdditionalStatus: AccountRefreshAdditionalStatus? {
        get {
            if let rawValue = refreshAdditionalStatusRawValue {
                return AccountRefreshAdditionalStatus(rawValue: rawValue)
            }
            return nil
        }
        set {
            refreshAdditionalStatusRawValue = newValue?.rawValue
        }
    }
    
    // MARK: - Update from response
    
    internal func update(response: APIUniqueResponse) {
        if let providerAccountResponse = response as? APIProviderAccountResponse {
            update(response: providerAccountResponse)
        }
    }
    
    internal func update(response: APIProviderAccountResponse) {
        providerAccountID = response.id
        providerID = response.providerID
        editable = response.editable
        lastRefreshed = response.refreshStatus.lastRefreshed
        nextRefresh = response.refreshStatus.nextRefresh
        refreshStatus = response.refreshStatus.status
        refreshSubStatus = response.refreshStatus.subStatus
        refreshAdditionalStatus = response.refreshStatus.additionalStatus
    }
    
}
