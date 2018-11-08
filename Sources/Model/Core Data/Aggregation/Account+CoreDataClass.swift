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

/**
 Account
 
 Core Data model of the account.
 */
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
    
    /**
     Account Status
     
     Status of the account according to the `Provider`
    */
    public enum AccountStatus: String, Codable {
        
        /// Account is fully active
        case active
        
        /// Account has been closed
        case closed
        
        /// Account is inactive (usually no transactions or other information)
        case inactive
        
        /// Account is about to be closed
        case toBeClosed = "to_be_closed"
        
    }
    
    /**
     Account Sub Type
     
     Sub type of the account indicating more detail what the account is
    */
    public enum AccountSubType: String, Codable {
        
        /// Bank - CD
        case cd
        
        /// Bank - Checking
        case checking
        
        /// Bank - Savings
        case savings
        
        
        
        /// Credit Card - Credit
        case credit
        
        /// Credit Card - Charge
        case charge
        
        
        
        /// Credit Score - Experian
        case experian
        
        
        
        /// Insurance
        case insurance
        
        
        
        /// Bill
        case bill
        
        
        
        /// Loan
        case loan
        
        
        
        /// Investment - 401K
        case t401k
        
        /// Investment - 403B
        case t403b
        
        /// Investment - Annuity
        case annuity
        
        /// Investment - Brokerage Cash
        case brokerageCash = "brokerage_cash"
        
        /// Investment - Brokerage Margin
        case brokerageMargin = "brokerage_margin"
        
        /// Investment - Custodial
        case custodial
        
        /// Investment - IRA
        case ira
        
        /// Investment - Individual
        case individual
        
        /// Investment - Market
        case market
        
        /// Investment - Money
        case money
        
        /// Investment - Money Market
        case moneyMarket = "money_market"
        
        /// Invesmtent - Simple
        case simple
        
        /// Investment - Trust
        case trust

        
        
        /// Unknown
        case unknown
        
        /// Other
        case other
        
    }
    
    /**
     Account Type
     
     Main type of the account as determined by container
    */
    public enum AccountType: String, Codable {
        
        /// Bank account
        case bank
        
        /// Biller account
        case bill
        
        /// Credit card
        case creditCard = "credit_card"
        
        /// Credit Score
        case creditScore = "credit_score"
        
        /// Insurance
        case insurance
        
        /// Investment
        case investment
        
        /// Loan
        case loan
        
        /// Reward/Loyalty Account
        case reward
        
        /// Unknown
        case unknown
        
    }
    
    /**
     Account Classification
     
     More detailed classification of the type of account
    */
    public enum Classification: String, Codable {
        
        /// Add on card account
        case addOnCard = "add_on_card"
        
        /// Corporate account
        case corporate
        
        /// Other account
        case other
        
        /// Personal account
        case personal
        
        /// Small business account
        case smallBusiness = "small_business"
        
        /// Trust account
        case trust
        
        /// Virtual card account
        case virtualCard = "virtual_card"
        
    }
    
    /// Core Data entity description name
    static var entityName = "Account"
    
    /// Account Status
    public var accountStatus: AccountStatus {
        get {
            return AccountStatus(rawValue: accountStatusRawValue)!
        }
        set {
            accountStatusRawValue = newValue.rawValue
        }
    }
    
    /// Account Sub Type
    public var accountSubType: AccountSubType {
        get {
            return AccountSubType(rawValue: accountSubTypeRawValue)!
        }
        set {
            accountSubTypeRawValue = newValue.rawValue
        }
    }
    
    /// Account Type
    public var accountType: AccountType {
        get {
            return AccountType(rawValue: accountTypeRawValue)!
        }
        set {
            accountTypeRawValue = newValue.rawValue
        }
    }
    
    /// Account Classification (optional)
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
    
    /// Account Refresh Status
    public var refreshStatus: AccountRefreshStatus {
        get {
            return AccountRefreshStatus(rawValue: refreshStatusRawValue!)!
        }
        set {
            refreshStatusRawValue = newValue.rawValue
        }
    }
    
    /// Account Refresh Sub Status (optional)
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
    
    /// Account Refresh Additional Status (optional)
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
    
    internal func linkObject(object: CacheableManagedObject) {
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let accountResponse = response as? APIAccountResponse {
            update(response: accountResponse, context: context)
        }
    }
    
    internal func update(response: APIAccountResponse, context: NSManagedObjectContext) {
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
        if let tiers = balanceTiers {
            removeFromBalanceTiers(tiers)
            
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
    
    internal func updateRequest() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(favourite: favourite,
                                       hidden: hidden,
                                       included: included,
                                       nickName: nickName)
    }

}
