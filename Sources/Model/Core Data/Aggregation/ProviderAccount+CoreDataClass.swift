//
//  ProviderAccount+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import CoreData
import Foundation

/**
 Provider Account
 
 Core Data representation of an account login for a `Provider`
 */
public class ProviderAccount: NSManagedObject, UniqueManagedObject {
    
    internal var primaryID: Int64 {
        return providerAccountID
    }
    
    /// Core Data entity description name
    static let entityName = "ProviderAccount"
    
    internal static var primaryKey = #keyPath(ProviderAccount.providerAccountID)
    
    /// Login Form for MFA etc (optional)
    public var loginForm: ProviderLoginForm? {
        get {
            if let rawValue = loginFormRawValue {
                let decoder = JSONDecoder()
                
                do {
                    return try decoder.decode(ProviderLoginForm.self, from: rawValue)
                } catch {
                    Log.error(error.localizedDescription)
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                
                do {
                    loginFormRawValue = try encoder.encode(newRawValue)
                } catch {
                    loginFormRawValue = nil
                }
            } else {
                loginFormRawValue = nil
            }
        }
    }
    
    /// Refresh status
    public var refreshStatus: AccountRefreshStatus {
        get {
            return AccountRefreshStatus(rawValue: refreshStatusRawValue)!
        }
        set {
            refreshStatusRawValue = newValue.rawValue
        }
    }
    
    /// Refresh sub status (optional)
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
    
    /// Refresh additional status (optional)
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
    
    internal func linkObject(object: NSManagedObject) {
        if let account = object as? Account {
            addToAccounts(account)
        }
    }
    
    // MARK: - Update from response
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let providerAccountResponse = response as? APIProviderAccountResponse {
            update(response: providerAccountResponse, context: context)
        }
    }
    
    internal func update(response: APIProviderAccountResponse, context: NSManagedObjectContext) {
        providerAccountID = response.id
        providerID = response.providerID
        editable = response.editable
        lastRefreshed = response.refreshStatus.lastRefreshed
        nextRefresh = response.refreshStatus.nextRefresh
        refreshStatus = response.refreshStatus.status
        refreshSubStatus = response.refreshStatus.subStatus
        refreshAdditionalStatus = response.refreshStatus.additionalStatus
        loginForm = response.loginForm
    }
    
}
