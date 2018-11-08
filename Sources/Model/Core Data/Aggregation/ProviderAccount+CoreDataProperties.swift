//
//  ProviderAccount+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension ProviderAccount {

    /**
     Fetch Request
     
     - returns: Fetch request for `Account` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProviderAccount> {
        return NSFetchRequest<ProviderAccount>(entityName: "ProviderAccount")
    }

    /// Editable by the user
    @NSManaged public var editable: Bool
    
    /// Date the aggregator last refreshed the provider account
    @NSManaged public var lastRefreshed: Date?
    
    /// Raw value of login form. Do not use.
    @NSManaged public var loginFormRawValue: Data?
    
    /// Next refresh date by the aggregator
    @NSManaged public var nextRefresh: Date?
    
    /// Unique ID for the provider account
    @NSManaged public var providerAccountID: Int64
    
    /// Parent provider ID
    @NSManaged public var providerID: Int64
    
    /// Raw value of the refresh additional status. Use only in predicates (optional)
    @NSManaged public var refreshAdditionalStatusRawValue: String?
    
    /// Raw value of the refresh status. Use only in predicates
    @NSManaged public var refreshStatusRawValue: String
    
    /// Raw value of the refresh sub status. Use only in predicates (optional)
    @NSManaged public var refreshSubStatusRawValue: String?
    
    /// Child accounts
    @NSManaged public var accounts: Set<Account>?
    
    /// Parent provider
    @NSManaged public var provider: Provider?

}

// MARK: Generated accessors for accounts
extension ProviderAccount {

    /// Add an account relationship
    @objc(addAccountsObject:)
    @NSManaged public func addToAccounts(_ value: Account)

    /// Remove an account relationship
    @objc(removeAccountsObject:)
    @NSManaged public func removeFromAccounts(_ value: Account)

    /// Add account relationships
    @objc(addAccounts:)
    @NSManaged public func addToAccounts(_ values: Set<Account>)

    /// Remove account relationships
    @objc(removeAccounts:)
    @NSManaged public func removeFromAccounts(_ values: Set<Account>)

}
