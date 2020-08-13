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

extension Account {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Account` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }
    
    /// Name of the account holder (optional)
    @NSManaged public var accountHolderName: String?
    
    /// Unique ID of the account
    @NSManaged public var accountID: Int64
    
    /// Name of the account (optional)
    @NSManaged public var accountName: String?
    
    /// Account number of the account (optional)
    @NSManaged public var accountNumber: String?
    
    /// Raw value for the account status. Use only in predicates
    @NSManaged public var accountStatusRawValue: String
    
    /// Raw value for the account sub type. Use only in predicates
    @NSManaged public var accountSubTypeRawValue: String
    
    /// Raw value for the account type. Use only in predicates
    @NSManaged public var accountTypeRawValue: String
    
    /// Amount due, for example monthly for a credit card (optional)
    @NSManaged public var amountDue: NSDecimalNumber?
    
    /// Amount due currency ISO code (optional)
    @NSManaged public var amountDueCurrency: String?
    
    /// APR percentage (optional)
    @NSManaged public var apr: NSDecimalNumber?
    
    /// Available balance (optional)
    @NSManaged public var availableBalance: NSDecimalNumber?
    
    /// Available balance currency ISO code (optional)
    @NSManaged public var availableBalanceCurrency: String?
    
    /// Available cash (optional)
    @NSManaged public var availableCash: NSDecimalNumber?
    
    /// Available cash currency (optional)
    @NSManaged public var availableCashCurrency: String?
    
    /// Available credit (optional)
    @NSManaged public var availableCredit: NSDecimalNumber?
    
    /// Available credit currency ISO code (optional)
    @NSManaged public var availableCreditCurrency: String?
    
    /// Description of the current account balance tier (optional)
    @NSManaged public var balanceDescription: String?
    
    /// BSB of the account (optional)
    @NSManaged public var bsb: String?
    
    /// Raw value of the account classification. Use only in predicates (optional)
    @NSManaged public var classificationRawValue: String?
    
    /// Current balance (optional)
    @NSManaged public var currentBalance: NSDecimalNumber?
    
    /// Current balance currency ISO code (optional)
    @NSManaged public var currentBalanceCurrency: String?
    
    /// Next due date on the account (optional)
    @NSManaged public var dueDate: Date?
    
    /// External ID of the object - i.e. the internal ID used by a provider
    @NSManaged public var externalID: String?
    
    /// Favourited
    @NSManaged public var favourite: Bool
    
    /// Raw value for the account features
    @NSManaged public var featuresRawValue: Data?
    
    /// Raw value for the associated goal IDs
    @NSManaged public var goalIDsRawValue: Data?
    
    /// Raw value for the account group. Use only in predicates
    @NSManaged public var groupRawValue: String
    
    /// Hidden. Used to hide the account in the UI
    @NSManaged public var hidden: Bool
    
    /// Included in budget. Used to exclude accounts from counting towards the user's budgets
    @NSManaged public var included: Bool
    
    /// Interest rate percentage (optional)
    @NSManaged public var interestRate: NSDecimalNumber?
    
    /// Last payment amount (optional)
    @NSManaged public var lastPaymentAmount: NSDecimalNumber?
    
    /// Last payment amount currency ISO code (optional)
    @NSManaged public var lastPaymentAmountCurrency: String?
    
    /// Date the last payment was made (optional)
    @NSManaged public var lastPaymentDate: Date?
    
    /// Date the aggregator last refreshed the account (optional)
    @NSManaged public var lastRefreshed: Date?
    
    /// Minimum amount due (optional)
    @NSManaged public var minimumAmountDue: NSDecimalNumber?
    
    /// Minimum amount due currency ISO code (optional)
    @NSManaged public var minimumAmountDueCurrency: String?
    
    /// Next refresh date by the aggregator (optional)
    @NSManaged public var nextRefresh: Date?
    
    /// Nickname given to the account for display and identification purposes (optional)
    @NSManaged public var nickName: String?
    
    /// URL of product details page (optional); Nil if product not selected
    @NSManaged public var productDetailsPageURL: String?
    
    /// ID of selected Product for this Account (optional, -1 is not selected)
    @NSManaged public var productID: Int64
    
    /// Name of selected Product for this Account (optional); Nil if product not selected
    @NSManaged public var productName: String?
    
    /// ProductsAvailable. True if CDR Products are available for this Account
    @NSManaged public var productsAvailable: Bool
    
    /// Parent provider account ID
    @NSManaged public var providerAccountID: Int64
    
    /// Name of the provider convenience property (optional)
    @NSManaged public var providerName: String?
    
    /// Raw value of the refresh additional status. Use only in predicate (optional)
    @NSManaged public var refreshAdditionalStatusRawValue: String?
    
    /// Raw value of the refresh status. Use only in predicates
    @NSManaged public var refreshStatusRawValue: String
    
    /// Raw value of the refresh sub status. Use only in predicate (optional)
    @NSManaged public var refreshSubStatusRawValue: String?
    
    /// Total cash limit (optional)
    @NSManaged public var totalCashLimit: NSDecimalNumber?
    
    /// Total cash limit currency ISO code (optional)
    @NSManaged public var totalCashLimitCurrency: String?
    
    /// Total credit line (optional)
    @NSManaged public var totalCreditLine: NSDecimalNumber?
    
    /// Total credit line currency (optional)
    @NSManaged public var totalCreditLineCurrency: String?
    
    /// Account balance tiers (optional)
    @NSManaged public var balanceTiers: Set<AccountBalanceTier>?
    
    /// Associated bills (optional)
    @NSManaged public var bills: Set<Bill>?
    
    /// Associated goals (optional)
    @NSManaged public var goals: Set<Goal>?
    
    /// CDR Product Informations  (optional)
    @NSManaged public var productInformations: Set<CDRProductInformation>?
    
    /// Parent provider account
    @NSManaged public var providerAccount: ProviderAccount?
    
    /// Balance reports
    @NSManaged public var reports: Set<ReportAccountBalance>?
    
    /// Child transactions
    @NSManaged public var transactions: Set<Transaction>?
    
}

// MARK: Generated accessors for balanceTiers

extension Account {
    
    /// Add an account balance tier relationship
    @objc(addBalanceTiersObject:)
    @NSManaged public func addToBalanceTiers(_ value: AccountBalanceTier)
    
    /// Remove an account balance tier relationship
    @objc(removeBalanceTiersObject:)
    @NSManaged public func removeFromBalanceTiers(_ value: AccountBalanceTier)
    
    /// Add account balance tier relationships
    @objc(addBalanceTiers:)
    @NSManaged public func addToBalanceTiers(_ values: Set<AccountBalanceTier>)
    
    /// Remove account balance tier relationships
    @objc(removeBalanceTiers:)
    @NSManaged public func removeFromBalanceTiers(_ values: Set<AccountBalanceTier>)
    
}

// MARK: Generated accessors for bills

extension Account {
    
    /// Add a bill relationship
    @objc(addBillsObject:)
    @NSManaged public func addToBills(_ value: Bill)
    
    /// Remove a bill relationship
    @objc(removeBillsObject:)
    @NSManaged public func removeFromBills(_ value: Bill)
    
    /// Add bill relationships
    @objc(addBills:)
    @NSManaged public func addToBills(_ values: Set<Bill>)
    
    /// Remove bill relationships
    @objc(removeBills:)
    @NSManaged public func removeFromBills(_ values: Set<Bill>)
    
}

// MARK: Generated accessors for goals

extension Account {
    
    /// Add a goal relationship
    @objc(addGoalsObject:)
    @NSManaged public func addToGoals(_ value: Goal)
    
    /// Remove a goal relationship
    @objc(removeGoalsObject:)
    @NSManaged public func removeFromGoals(_ value: Goal)
    
    /// Add goal relationships
    @objc(addGoals:)
    @NSManaged public func addToGoals(_ values: Set<Goal>)
    
    /// Remove goal relationships
    @objc(removeGoals:)
    @NSManaged public func removeFromGoals(_ values: Set<Goal>)
    
}

// MARK: Generated accessors for reports

extension Account {
    
    /// Add a account balance report relationship
    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: ReportAccountBalance)
    
    /// Remove a account balance report relationship
    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: ReportAccountBalance)
    
    /// Add account balance report relationships
    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)
    
    /// Remove account balance report relationships
    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)
    
}

// MARK: Generated accessors for transactions

extension Account {
    
    /// Add a transaction relationship
    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)
    
    /// Remove a transaction relationship
    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)
    
    /// Add transaction relationships
    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: Set<Transaction>)
    
    /// Remove transaction relationships
    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: Set<Transaction>)
    
}

// MARK: Generated accessors for productInformations

extension Account {
    
    /// Add an CDR product information relationship
    @objc(addProductInformationsObject:)
    @NSManaged public func addToProductInformations(_ value: CDRProductInformation)
    
    /// Remove an CDR product information relationship
    @objc(removeProductInformationsObject:)
    @NSManaged public func removeFromProductInformations(_ value: CDRProductInformation)
    
    /// Add CDR product information relationships
    @objc(addProductInformations:)
    @NSManaged public func addToProductInformations(_ values: Set<CDRProductInformation>)
    
    /// Remove CDR product information relationships
    @objc(removeProductInformations:)
    @NSManaged public func removeFromProductInformations(_ values: Set<CDRProductInformation>)
    
}
