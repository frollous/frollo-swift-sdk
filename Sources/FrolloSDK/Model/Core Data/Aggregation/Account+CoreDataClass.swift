//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//

import CoreData
import Foundation

/**
 Account
 
 Core Data model of the account.
 */
public class Account: NSManagedObject, UniqueManagedObject {
    
    internal var primaryID: Int64 {
        return accountID
    }
    
    /**
     Account Feature
     
     Represents features which are available in this account
     */
    public struct AccountFeature: Codable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case imageURL = "image_url"
            case details
        }
        
        /// Feature ID
        public let id: AccountFeatureType
        
        /// Feature name (optional)
        public let name: String?
        
        /// Feature image url (optional)
        public let imageURL: String?
        
        /// Array of `AccountFeatureDetail`
        public let details: [AccountFeatureDetail]?
    }
    
    /**
     AccountFeatureType
     
     Type of `AccountFeature`
     */
    public enum AccountFeatureType: String, Codable, CaseIterable {
        
        /// Payment feature
        case payments
        
        /// Transfers feature
        case transfers
        
        /// Statements feature
        case statements
        
    }
    
    /**
     Account Feature Detail
     
     Represents details of the `AccountFeature`
     */
    public struct AccountFeatureDetail: Codable {
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case imageURL = "image_url"
        }
        
        /// Feature detail ID
        public let id: AccountFeatureSubType
        
        /// Feature detail name (optional)
        public let name: String?
        
        /// Feature detail image url (optional)
        public let imageURL: String?
    }
    
    /**
     AccountFeatureSubType
     
     Subtype of `AccountFeatureType`
     */
    public enum AccountFeatureSubType: String, Codable, CaseIterable {
        
        /// bpay Payment feature subtype
        case bpay
        
        /// npp Payment feature subtype
        case npp
        
        /// payAnyone Payment feature subtype
        case payAnyone = "pay_anyone"
        
        /// internal Transfer feature subtype
        case internalTransfer = "internal"
        
    }
    
    /**
     Account Status
     
     Status of the account according to the `Provider`
     */
    public enum AccountStatus: String, Codable, CaseIterable {
        
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
    public enum AccountSubType: String, Codable, CaseIterable {
        
        /// Other or unknown sub type
        case other
        
        /// Bank account
        case bankAccount = "bank_account"
        
        /// Savings account
        case savings
        
        /// Emergency savings fund
        case emergencyFund = "emergency_fund"
        
        /// Term deposit
        case termDeposit = "term_deposit"
        
        /// Bills fund
        case bills
        
        /// Offset account
        case offset
        
        /// Travel Card
        case travel
        
        /// Prepaid Card
        case prepaid
        
        /// Balance transfer card
        case balanceTransferCard = "balance_transfer_card"
        
        /// Reward points card
        case rewardsCard = "rewards_card"
        
        /// Generic credit card
        case creditCard = "credit_card"
        
        /// Super Annuation
        case superAnnuation = "super_annuation"
        
        /// Shares and Stocks
        case shares
        
        /// Business account
        case business
        
        /// Bonds
        case bonds
        
        /// Pension
        case pension
        
        /// Generic Mortgage
        case mortgage
        
        /// Mortgage - Fixed Rate
        case mortgageFixed = "mortgage_fixed"
        
        /// Mortgage - Variable Rate
        case mortgageVariable = "mortgage_variable"
        
        /// Investment Home Loan - Fixed Rate
        case investmentHomeLoanFixed = "investment_home_loan_fixed"
        
        /// Investment Home Loan - Variable
        case investmentHomeLoanVariable = "investment_home_loan_variable"
        
        /// Student Loan
        case studentLoan = "student_loan"
        
        /// Car Loan
        case carLoan = "car_loan"
        
        /// Line of Credit
        case lineOfCredit = "line_of_credit"
        
        /// Peer to Peer Loan
        case p2pLending = "p2p_lending"
        
        /// Personal Loan
        case personal
        
        /// Car insurance
        case autoInsurance = "auto_insurance"
        
        /// Health insurance
        case healthInsurance = "health_insurance"
        
        /// Home insurnace
        case homeInsurance = "home_insurance"
        
        /// Life insurance
        case lifeInsurance = "life_insurance"
        
        /// Travel Insurance
        case travelInsurance = "travel_insurance"
        
        /// Generic Insurance
        case insurance
        
        /// Reward or Loyalty
        case reward
        
        /// Credit Score
        case creditScore = "credit_score"
        
        /// Financial Health Score
        case healthScore = "health_score"
        
    }
    
    /**
     Account Type
     
     Main type of the account as determined by container
     */
    public enum AccountType: String, Codable, CaseIterable {
        
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
    public enum Classification: String, Codable, CaseIterable {
        
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
    
    /**
     Grouping of Accounts
     
     What account group the account should appear in
     */
    public enum Group: String, Codable, CaseIterable {
        
        /// Bank accounts
        case bank
        
        /// Savings accounts
        case savings
        
        /// Credit cards
        case creditCard = "credit_card"
        
        /// Super Annuation
        case superAnnuation = "super_annuation"
        
        /// Investments
        case investment
        
        /// Loans and mortgages
        case loan
        
        /// Insurance
        case insurance
        
        /// Rewards and Loyalty
        case reward
        
        /// Scores
        case score
        
        /// Custom section (as defined per tenant)
        case custom
        
        /// Other or unknown
        case other
        
    }
    
    /// Core Data entity description name
    static var entityName = "Account"
    
    internal static var primaryKey = #keyPath(Account.accountID)
    
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
    
    /// An array of `AccountFeature` decoded from a json array stored in the database. (Optional)
    public var features: [AccountFeature]? {
        get {
            if let featuresRawValue = featuresRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let features = try decoder.decode([AccountFeature].self, from: featuresRawValue)
                    return features
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    featuresRawValue = try encoder.encode(newRawValue)
                } catch {
                    featuresRawValue = nil
                }
            } else {
                featuresRawValue = nil
            }
        }
    }
    
    /// An array of Goal IDs decoded from a json array stored in the database. (Optional)
    public var goalIDs: [Int64]? {
        get {
            if let goalIDsData = goalIDsRawValue {
                let decoder = JSONDecoder()
                
                do {
                    let goalIDs = try decoder.decode([Int64].self, from: goalIDsData)
                    return goalIDs
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                do {
                    goalIDsRawValue = try encoder.encode(newRawValue)
                } catch {
                    goalIDsRawValue = nil
                }
            } else {
                goalIDsRawValue = nil
            }
        }
    }
    
    /// Account Grouping
    public var group: Group {
        get {
            return Group(rawValue: groupRawValue)!
        }
        set {
            groupRawValue = newValue.rawValue
        }
    }
    
    /// Account Refresh Status
    public var refreshStatus: AccountRefreshStatus {
        get {
            return AccountRefreshStatus(rawValue: refreshStatusRawValue)!
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
    
    internal func linkObject(object: NSManagedObject) {
        if let bill = object as? Bill {
            addToBills(bill)
        }
        if let goal = object as? Goal {
            addToGoals(goal)
        }
        if let report = object as? ReportAccountBalance {
            addToReports(report)
        }
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
        if let card = object as? Card {
            addToCards(card)
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
        accountSubType = response.accountAttributes.accountType
        accountType = response.accountAttributes.container
        externalID = response.externalID
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
        
        accountNumber = response.accountNumber
        accountHolderName = response.holderProfile?.name
        balanceDescription = response.balanceDetails?.currentDescription
        bsb = response.bsb
        classification = response.accountAttributes.classification
        features = response.features
        group = response.accountAttributes.group
        dueDate = response.dueDate
        goalIDs = response.goalIDs
        lastPaymentDate = response.lastPaymentDate
        lastRefreshed = response.refreshStatus.lastRefreshed
        nextRefresh = response.refreshStatus.nextRefresh
        refreshAdditionalStatus = response.refreshStatus.additionalStatus
        refreshStatus = response.refreshStatus.status
        refreshSubStatus = response.refreshStatus.subStatus
        nickName = response.nickName
        productID = response.cdrProduct?.id ?? -1
        productName = response.cdrProduct?.name
        productDetailsPageURL = response.cdrProduct?.productDetailsPageURL
        productsAvailable = response.productsAvailable
        
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
        
        // CDR Product Informations
        if let productInformations = productInformations {
            
            removeFromProductInformations(productInformations)
            
            for productInformation in productInformations {
                managedObjectContext?.delete(productInformation)
            }
        }
        
        if let productInformations = response.cdrProduct?.cdrProductInformations {
            for productInformation in productInformations {
                let accountProductInformation = CDRProductInformation(context: context)
                accountProductInformation.update(response: productInformation)
                
                addToProductInformations(accountProductInformation)
            }
        }
    }
    
    internal func updateRequest() -> APIAccountUpdateRequest {
        return APIAccountUpdateRequest(accountType: accountSubType,
                                       favourite: favourite,
                                       hidden: hidden,
                                       included: included,
                                       nickName: nickName,
                                       productID: productID != -1 ? productID : nil)
    }
    
}
