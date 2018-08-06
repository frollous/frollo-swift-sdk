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
    
    func update(response: APIUniqueResponse) {
        if let accountResponse = response as? APIAccountResponse {
            update(response: accountResponse)
        }
    }
    
    func update(response: APIAccountResponse) {
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
        
        amountDue = response.amountDue?.amount as NSDecimalNumber?
        amountDueCurrency = response.amountDue?.currency
        availableBalance = response.availableBalance?.amount as NSDecimalNumber?
        availableBalanceCurrency = response.availableBalance?.currency
        availableCash = response.availableCash?.amount as NSDecimalNumber?
        availableCashCurrency = response.availableCash?.currency
        availableCredit = response.availableCredit?.amount as NSDecimalNumber?
        availableCreditCurrency = response.availableCredit?.currency
        currentBalance = response.currentBalance?.amount as NSDecimalNumber?
        currentBalanceCurrency = response.currentBalance?.currency
        lastPaymentAmount = response.lastPaymentAmount?.amount as NSDecimalNumber?
        lastPaymentAmountCurrency = response.lastPaymentAmount?.currency
        minimumAmountDue = response.minimumAmountDue?.amount as NSDecimalNumber?
        minimumAmountDueCurrency = response.minimumAmountDue?.currency
        totalCashLimit = response.totalCashLimit.amount as NSDecimalNumber?
        totalCashLimitCurrency = response.totalCashLimit.currency
        totalCreditLine = response.totalCreditLine.amount as NSDecimalNumber?
        totalCreditLineCurrency = response.totalCreditLine.currency
        
        // Optionals
        
        accountHolderName = response.holderProfile?.name
        balanceDescription = response.balanceDetails?.currentDescription
        classification = response.classification
        apr = response.apr as NSDecimalNumber?
        interestRate = response.interestRate as NSDecimalNumber?
        dueDate = response.dueDate
        lastPaymentDate = response.lastPaymentDate
        lastRefreshed = response.refreshStatus.lastRefreshed
        nextRefresh = response.refreshStatus.nextRefresh
        refreshAdditionalStatus = response.refreshStatus.additionalStatus
        refreshStatus = response.refreshStatus.status
        refreshSubStatus = response.refreshStatus.subStatus
        nickName = response.nickName
    }

}
