//
//  Account+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Account)
public class Account: NSManagedObject, CacheableManagedObject {
    
    internal var primaryID: Int64 {
        get {
            return accountID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return providerAccountID
        }
    }
    
    public enum AccountStatus: String, Codable {
        case active
        case closed
        case inactive
        case toBeClosed = "to_be_closed"
    }
    
    public enum AccountSubType: String, Codable {
        case cd
        case market
        case money
        case savings
        case credit
        case charge
        case experian
        case individual
        case insurance
        case bill
        case loan
        case brokerageCash = "brokerage_cash"
        case brokerageMargin = "brokerage_margin"
        case moneyMarket = "money_market"
        case ira
        case t401k
        case t403b
        case trust
        case annuity
        case simple
        case custodian
        case unknown
        case other
        case checking
    }
    
    public enum AccountType: String, Codable {
        case bank
        case bill
        case creditCard = "credit_card"
        case creditScore = "credit_score"
        case insurance
        case investment
        case loan
        case reward
        case unknown
    }
    
    public enum Classification: String, Codable {
        case addOnCard = "add_on_card"
        case corporate
        case other
        case personal
        case smallBusiness = "small_business"
        case trust
        case virtualCard = "virtual_card"
    }
    
    static var entityName = "Account"
    
    public var accountStatus: AccountStatus {
        get {
            return AccountStatus(rawValue: accountStatusRawValue!)!
        }
        set {
            accountStatusRawValue = newValue.rawValue
        }
    }
    
    public var accountSubType: AccountSubType {
        get {
            return AccountSubType(rawValue: accountSubTypeRawValue!)!
        }
        set {
            accountSubTypeRawValue = newValue.rawValue
        }
    }
    
    public var accountType: AccountType {
        get {
            return AccountType(rawValue: accountTypeRawValue!)!
        }
        set {
            accountTypeRawValue = newValue.rawValue
        }
    }
    
    public var classification: Classification? {
        get {
            if let rawValue = classificationRawValue {
                return Classification(rawValue: rawValue)
            }
            return nil
        }
        set {
            classificationRawValue = newValue?.rawValue
        }
    }
    
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
    
    // MARK: - Updating object
    
    func linkObject(object: CacheableManagedObject) {
        // TODO: Implement account link
    }
    
    func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let accountResponse = response as? APIAccountResponse {
            update(response: accountResponse, context: context)
        }
    }
    
    func update(response: APIAccountResponse, context: NSManagedObjectContext) {
        accountID = response.id
        providerAccountID = response.providerAccountID
        providerName = response.providerName
        accountName = response.accountName
        accountStatus = response.accountStatus
        accountSubType = response.accountType
        accountType = response.container
        favourite = response.favourite
        hidden = response.hidden
        included = response.included
        
        // Optional balances
        
        if let balance = response.amountDue {
            amountDue = NSDecimalNumber(string: balance.amount)
            amountDueCurrency = balance.currency
        } else {
            amountDue = nil
            amountDueCurrency = nil
        }
        if let balance = response.availableBalance {
            availableBalance = NSDecimalNumber(string: balance.amount)
            availableBalanceCurrency = balance.currency
        } else {
            availableBalance = nil
            availableBalanceCurrency = nil
        }
        if let balance = response.availableCash {
            availableCash = NSDecimalNumber(string: balance.amount)
            availableCashCurrency = balance.currency
        } else {
            availableCash = nil
            availableCashCurrency = nil
        }
        if let balance = response.availableCredit {
            availableCredit = NSDecimalNumber(string: balance.amount)
            availableCreditCurrency = balance.currency
        } else {
            availableCredit = nil
            availableCreditCurrency = nil
        }
        if let balance = response.currentBalance {
            currentBalance = NSDecimalNumber(string: balance.amount)
            currentBalanceCurrency = balance.currency
        } else {
            currentBalance = nil
            currentBalanceCurrency = nil
        }
        if let balance = response.lastPaymentAmount {
            lastPaymentAmount = NSDecimalNumber(string: balance.amount)
            lastPaymentAmountCurrency = balance.currency
        } else {
            lastPaymentAmount = nil
            lastPaymentAmountCurrency = nil
        }
        if let balance = response.minimumAmountDue {
            minimumAmountDue = NSDecimalNumber(string: balance.amount)
            minimumAmountDueCurrency = balance.currency
        } else {
            minimumAmountDue = nil
            minimumAmountDueCurrency = nil
        }
        if let balance = response.totalCashLimit {
            totalCashLimit = NSDecimalNumber(string: balance.amount)
            totalCashLimitCurrency = balance.currency
        } else {
            totalCashLimit = nil
            totalCashLimitCurrency = nil
        }
        if let balance = response.totalCreditLine {
            totalCreditLine = NSDecimalNumber(string: balance.amount)
            totalCreditLineCurrency = balance.currency
        } else {
            totalCreditLine = nil
            totalCreditLineCurrency = nil
        }
        
        // Optionals
        
        accountHolderName = response.holderProfile?.name
        balanceDescription = response.balanceDetails?.currentDescription
        classification = response.classification
        dueDate = response.dueDate
        lastPaymentDate = response.lastPaymentDate
        lastRefreshed = response.refreshStatus.lastRefreshed
        nextRefresh = response.refreshStatus.nextRefresh
        refreshAdditionalStatus = response.refreshStatus.additionalStatus
        refreshStatus = response.refreshStatus.status
        refreshSubStatus = response.refreshStatus.subStatus
        nickName = response.nickName
        
        if let updatedAPR = response.apr {
            apr = NSDecimalNumber(string: updatedAPR)
        } else {
            apr = nil
        }
        if let updatedInterestRate = response.interestRate {
            interestRate = NSDecimalNumber(string: updatedInterestRate)
        } else {
            interestRate = nil
        }
        
        // Balance tiers
        
        if let tiers = balanceTiers as? Set<AccountBalanceTier> {
            removeFromBalanceTiers(tiers as NSSet)
            
            for tier in tiers {
                managedObjectContext?.delete(tier)
            }
        }
        
        if let tiers = response.balanceDetails?.tiers {
            for tier in tiers {
                let accountBalanceTier = AccountBalanceTier(context: context)
                accountBalanceTier.update(response: tier)
                
                addToBalanceTiers(accountBalanceTier)
            }
        }
    }

}
