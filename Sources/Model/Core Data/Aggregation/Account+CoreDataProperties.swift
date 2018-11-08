//
//  Account+CoreDataProperties.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 8/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var accountHolderName: String?
    @NSManaged public var accountID: Int64
    @NSManaged public var accountName: String?
    @NSManaged public var accountStatusRawValue: String?
    @NSManaged public var accountSubTypeRawValue: String?
    @NSManaged public var accountTypeRawValue: String?
    @NSManaged public var amountDue: NSDecimalNumber?
    @NSManaged public var amountDueCurrency: String?
    @NSManaged public var apr: NSDecimalNumber?
    @NSManaged public var availableBalance: NSDecimalNumber?
    @NSManaged public var availableBalanceCurrency: String?
    @NSManaged public var availableCash: NSDecimalNumber?
    @NSManaged public var availableCashCurrency: String?
    @NSManaged public var availableCredit: NSDecimalNumber?
    @NSManaged public var availableCreditCurrency: String?
    @NSManaged public var balanceDescription: String?
    @NSManaged public var classificationRawValue: String?
    @NSManaged public var currentBalance: NSDecimalNumber?
    @NSManaged public var currentBalanceCurrency: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var favourite: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var included: Bool
    @NSManaged public var interestRate: NSDecimalNumber?
    @NSManaged public var lastPaymentAmount: NSDecimalNumber?
    @NSManaged public var lastPaymentAmountCurrency: String?
    @NSManaged public var lastPaymentDate: Date?
    @NSManaged public var lastRefreshed: Date?
    @NSManaged public var minimumAmountDue: NSDecimalNumber?
    @NSManaged public var minimumAmountDueCurrency: String?
    @NSManaged public var nextRefresh: Date?
    @NSManaged public var nickName: String?
    @NSManaged public var providerAccountID: Int64
    @NSManaged public var providerName: String?
    @NSManaged public var refreshAdditionalStatusRawValue: String?
    @NSManaged public var refreshStatusRawValue: String?
    @NSManaged public var refreshSubStatusRawValue: String?
    @NSManaged public var totalCashLimit: NSDecimalNumber?
    @NSManaged public var totalCashLimitCurrency: String?
    @NSManaged public var totalCreditLine: NSDecimalNumber?
    @NSManaged public var totalCreditLineCurrency: String?
    @NSManaged public var balanceTiers: Set<AccountBalanceTier>?
    @NSManaged public var providerAccount: ProviderAccount?
    @NSManaged public var transactions: Set<Transaction>?

}

// MARK: Generated accessors for balanceTiers
extension Account {

    @objc(addBalanceTiersObject:)
    @NSManaged public func addToBalanceTiers(_ value: AccountBalanceTier)

    @objc(removeBalanceTiersObject:)
    @NSManaged public func removeFromBalanceTiers(_ value: AccountBalanceTier)

    @objc(addBalanceTiers:)
    @NSManaged public func addToBalanceTiers(_ values: Set<AccountBalanceTier>)

    @objc(removeBalanceTiers:)
    @NSManaged public func removeFromBalanceTiers(_ values: Set<AccountBalanceTier>)

}

// MARK: Generated accessors for transactions
extension Account {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: Set<Transaction>)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: Set<Transaction>)

}
