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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProviderAccount> {
        return NSFetchRequest<ProviderAccount>(entityName: "ProviderAccount")
    }

    @NSManaged public var editable: Bool
    @NSManaged public var lastRefreshed: Date?
    @NSManaged public var loginFormRawValue: Data?
    @NSManaged public var nextRefresh: Date?
    @NSManaged public var providerAccountID: Int64
    @NSManaged public var providerID: Int64
    @NSManaged public var refreshAdditionalStatusRawValue: String?
    @NSManaged public var refreshStatusRawValue: String?
    @NSManaged public var refreshSubStatusRawValue: String?
    @NSManaged public var accounts: Set<Account>?
    @NSManaged public var provider: Provider?

}

// MARK: Generated accessors for accounts
extension ProviderAccount {

    @objc(addAccountsObject:)
    @NSManaged public func addToAccounts(_ value: Account)

    @objc(removeAccountsObject:)
    @NSManaged public func removeFromAccounts(_ value: Account)

    @objc(addAccounts:)
    @NSManaged public func addToAccounts(_ values: Set<Account>)

    @objc(removeAccounts:)
    @NSManaged public func removeFromAccounts(_ values: Set<Account>)

}
