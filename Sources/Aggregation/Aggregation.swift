//
//  Aggregation.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

/// Manages all aggregation data including accounts, transactions, categories and merchants
public class Aggregation: CachedObjects, ResponseHandler {
    
    private let database: Database
    private let network: Network
    
    private let accountLock = NSLock()
    private let merchantLock = NSLock()
    private let providerLock = NSLock()
    private let providerAccountLock = NSLock()
    private let transactionLock = NSLock()
    private let transactionCategoryLock = NSLock()
    
    private var linkingProviderIDs = Set<Int64>()
    private var linkingProviderAccountIDs = Set<Int64>()
    private var linkingAccountIDs = Set<Int64>()
    private var linkingMerchantIDs = Set<Int64>()
    private var linkingTransactionCategoryIDs = Set<Int64>()
    private var refreshingProviderIDs = Set<Int64>()
    
    internal init(database: Database, network: Network) {
        self.database = database
        self.network = network
    }
    
    
    // MARK: - Providers
    
    /**
     Fetch provider by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - providerID: Unique provider ID to fetch
     */
    public func provider(context: NSManagedObjectContext, providerID: Int64) -> Provider? {
        return cachedObject(type: Provider.self, context: context, objectID: providerID, objectKey: #keyPath(Provider.providerID))
    }
    
    /**
     Fetch providers from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Provider` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerID ascending (Optional)
     */
    public func providers(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Provider.providerID), ascending: true)], limit: Int? = nil) -> [Provider]? {
        return cachedObjects(type: Provider.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Providers from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Provider` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerID ascending (Optional)
     */
    public func providersFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Provider.providerID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Provider>? {
        return fetchedResultsController(type: Provider.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available providers from the host.
     
     Includes beta and supported providers. Unsupported and Disabled providers must be fetched by ID.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshProviders(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchProviders { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providersResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProvidersResponse(providersResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Refresh a specific provider by ID from the host
     
     Fetches providers of any status.
     
     - parameters:
        - providerID: ID of the provider to fetch
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshProvider(providerID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchProvider(providerID: providerID) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providerResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderResponse(providerResponse, managedObjectContext: managedObjectContext)
                    
                    self.refreshingProviderIDs.remove(providerID)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Provider Accounts
    
    /**
     Fetch provider account by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - providerAccountID: Unique provider account ID to fetch
    */
    public func providerAccount(context: NSManagedObjectContext, providerAccountID: Int64) -> ProviderAccount? {
        return cachedObject(type: ProviderAccount.self, context: context, objectID: providerAccountID, objectKey: #keyPath(ProviderAccount.providerAccountID))
    }
    
    /**
     Fetch provider accounts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `ProviderAccount` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerAccountID ascending (Optional)
    */
    public func providerAccounts(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ProviderAccount.providerAccountID), ascending: true)], limit: Int? = nil) -> [ProviderAccount]? {
        return cachedObjects(type: ProviderAccount.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Provider Accounts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `ProviderAccount` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerAccountID ascending (Optional)
    */
    public func providerAccountsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ProviderAccount.providerAccountID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<ProviderAccount>? {
        return fetchedResultsController(type: ProviderAccount.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available provider accounts from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshProviderAccounts(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchProviderAccounts { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providerAccountsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountsResponse(providerAccountsResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
        
    }
    
    /**
     Refresh a specific provider account by ID from the host
     
     - parameters:
        - providerAccountID: ID of the provider account to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshProviderAccount(providerAccountID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchProviderAccount(providerAccountID: providerAccountID) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providerAccountResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountResponse(providerAccountResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Create a provider account
     
     - parameters:
        - providerID: ID of the provider which an account should be created for
        - loginForm: Provider login form with validated and encrypted values with the user's details
        - completion: Optional completion handler with optional error if the request fails
     */
    public func createProviderAccount(providerID: Int64, loginForm: ProviderLoginForm, completion: FrolloSDKCompletionHandler? = nil) {
        let request = APIProviderAccountCreateRequest(loginForm: loginForm, providerID: providerID)
        
        network.createProviderAccount(request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providerAccountRespone = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountResponse(providerAccountRespone, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Update a provider account on the host
     
     - parameters:
        - providerAccountID: ID of the provider account to be updated
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateProviderAccount(providerAccountID: Int64, loginForm: ProviderLoginForm, completion: FrolloSDKCompletionHandler? = nil) {
        let request = APIProviderAccountUpdateRequest(loginForm: loginForm)
        
        network.updateProviderAccount(providerAccountID: providerAccountID, request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let providerAccountRespone = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountResponse(providerAccountRespone, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Accounts
    
    /**
     Fetch account by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - accountID: Unique account ID to fetch
     */
    public func account(context: NSManagedObjectContext, accountID: Int64) -> Account? {
        return cachedObject(type: Account.self, context: context, objectID: accountID, objectKey: #keyPath(Account.accountID))
    }
    
    /**
     Fetch accounts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Account` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to accountID ascending (Optional)
     */
    public func accounts(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Account.accountID), ascending: true)], limit: Int? = nil) -> [Account]? {
        return cachedObjects(type: Account.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Accounts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Account` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to accountID ascending (Optional)
     */
    public func accountsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Account.accountID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Account>? {
        return fetchedResultsController(type: Account.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available accounts from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshAccounts(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchAccounts { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let accountsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountsResponse(accountsResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountsToProviderAccounts(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
        
    }
    
    /**
     Refresh a specific account by ID from the host
     
     - parameters:
        - accountID: ID of the account to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshAccount(accountID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchAccount(accountID: accountID) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let accountResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountResponse(accountResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountsToProviderAccounts(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Update an account on the host
     
     - parameters:
        - accountID: ID of the account to be updated
        - completion: Optional completion handler with optional error if the request fails
    */
    public func updateAccount(accountID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard let account = account(context: database.newBackgroundContext(), accountID: accountID)
            else {
                let error = DataError(type: .database, subType: .notFound)
                
                DispatchQueue.main.async {
                    completion?(error)
                }
                return
        }
        
        let request = account.updateRequest()
        
        network.updateAccount(accountID: accountID, request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let accountResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountResponse(accountResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountsToProviderAccounts(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Transactions
    
    /**
     Fetch transaction by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - transactionID: Unique transaction ID to fetch
     */
    public func transaction(context: NSManagedObjectContext, transactionID: Int64) -> Transaction? {
        return cachedObject(type: Transaction.self, context: context, objectID: transactionID, objectKey: #keyPath(Transaction.transactionID))
    }
    
    /**
     Fetch transactions from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Transaction` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionID ascending (Optional)
     */
    public func transactions(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Transaction.transactionID), ascending: true)], limit: Int? = nil) -> [Transaction]? {
        return cachedObjects(type: Transaction.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of transactions from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Transaction` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionID ascending (Optional)
     */
    public func transactionsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Transaction.transactionID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Transaction>? {
        return fetchedResultsController(type: Transaction.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh transactions from a certain period from the host
     
     - parameters:
        - fromDate: Start date to fetch transactions from (inclusive)
        - toDate: End date to fetch transactions up to (inclusive)
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshTransactions(from fromDate: Date, to toDate: Date, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchTransactions(from: fromDate, to: toDate) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let transactionResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionsResponse(transactionResponse, from: fromDate, to: toDate, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Refresh a specific transaction by ID from the host
     
     - parameters:
        - transactionID: ID of the transaction to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransaction(transactionID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchTransaction(transactionID: transactionID) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let transactionResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionResponse(transactionResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Refresh specific transactions by ID from the host
     
     - parameters:
         - transactionIDs: List of transaction IDs to fetch
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransactions(transactionIDs: [Int64], completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchTransactions(transactionIDs: transactionIDs) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let transactionResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionsResponse(transactionResponse, transactionIDs: transactionIDs, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Update a transaction on the host
     
     - parameters:
        - transactionID: ID of the transaction to be updated
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateTransaction(transactionID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard let transaction = transaction(context: database.newBackgroundContext(), transactionID: transactionID)
            else {
                let error = DataError(type: .database, subType: .notFound)
                
                DispatchQueue.main.async {
                    completion?(error)
                }
                return
        }
        
        let request = transaction.updateRequest()
        
        network.updateTransaction(transactionID: transactionID, request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let transactionResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionResponse(transactionResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Transaction Categories
    
    /**
     Fetch transaction category by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - transactionID: Unique transaction category ID to fetch
     */
    public func transactionCategory(context: NSManagedObjectContext, transactionCategoryID: Int64) -> TransactionCategory? {
        return cachedObject(type: TransactionCategory.self, context: context, objectID: transactionCategoryID, objectKey: #keyPath(TransactionCategory.transactionCategoryID))
    }
    
    /**
     Fetch transaction categories from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `TransactionCategory` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionCategoryID ascending (Optional)
     */
    public func transactionCategories(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(TransactionCategory.transactionCategoryID), ascending: true)], limit: Int? = nil) -> [TransactionCategory]? {
        return cachedObjects(type: TransactionCategory.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of transaction categories from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `TransactionCategory` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionCategoryID ascending (Optional)
     */
    public func transactionCategoriesFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(TransactionCategory.transactionCategoryID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<TransactionCategory>? {
        return fetchedResultsController(type: TransactionCategory.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all transaction categories from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshTransactionCategories(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchTransactionCategories { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let transactionCategoriesResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionCategoriesResponse(transactionCategoriesResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Merchants
    
    /**
     Fetch merchant by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - transactionID: Unique merchant ID to fetch
     */
    public func merchant(context: NSManagedObjectContext, merchantID: Int64) -> Merchant? {
        return cachedObject(type: Merchant.self, context: context, objectID: merchantID, objectKey: #keyPath(Merchant.merchantID))
    }
    
    /**
     Fetch merchants from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Merchant` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to merchantID ascending (Optional)
     */
    public func merchants(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)], limit: Int? = nil) -> [Merchant]? {
        return cachedObjects(type: Merchant.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of merchants from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Merchant` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to merchantID ascending (Optional)
     */
    public func merchantsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Merchant>? {
        return fetchedResultsController(type: Merchant.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all merchants from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
    */
    public func refreshMerchants(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchMerchants { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let merchantsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantsResponse(merchantsResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkProviderAccountsToProviders(managedObjectContext: NSManagedObjectContext) {
        providerLock.lock()
        providerAccountLock.lock()
        
        defer {
            providerLock.unlock()
            providerAccountLock.unlock()
        }
        
        let missingProviderIDs = linkObjectToParentObject(type: ProviderAccount.self, parentType: Provider.self, managedObjectContext: managedObjectContext, linkedIDs: linkingProviderIDs, linkedKey: \ProviderAccount.providerID, linkedKeyName: #keyPath(ProviderAccount.providerID))
        
        linkingProviderIDs = Set()
        
        for providerID in missingProviderIDs {
            guard !refreshingProviderIDs.contains(providerID)
                else {
                    continue
            }
            
            refreshingProviderIDs.insert(providerID)
            refreshProvider(providerID: providerID)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkAccountsToProviderAccounts(managedObjectContext: NSManagedObjectContext) {
        providerAccountLock.lock()
        accountLock.lock()
        
        defer {
            providerAccountLock.unlock()
            accountLock.unlock()
        }
        
        linkObjectToParentObject(type: Account.self, parentType: ProviderAccount.self, managedObjectContext: managedObjectContext, linkedIDs: linkingProviderAccountIDs, linkedKey: \Account.providerAccountID, linkedKeyName: #keyPath(Account.providerAccountID))
        
        linkingProviderAccountIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkTransactionsToAccounts(managedObjectContext: NSManagedObjectContext) {
        accountLock.lock()
        transactionLock.lock()
        
        defer {
            accountLock.unlock()
            transactionLock.unlock()
        }
        
        linkObjectToParentObject(type: Transaction.self, parentType: Account.self, managedObjectContext: managedObjectContext, linkedIDs: linkingAccountIDs, linkedKey: \Transaction.accountID, linkedKeyName: #keyPath(Transaction.accountID))
        
        linkingAccountIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkTransactionsToMerchants(managedObjectContext: NSManagedObjectContext) {
        merchantLock.lock()
        transactionLock.lock()
        
        defer {
            merchantLock.unlock()
            transactionLock.unlock()
        }
        
        linkObjectToParentObject(type: Transaction.self, parentType: Merchant.self, managedObjectContext: managedObjectContext, linkedIDs: linkingMerchantIDs, linkedKey: \Transaction.merchantID, linkedKeyName: #keyPath(Transaction.merchantID))
        
        linkingMerchantIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkTransactionsToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        transactionCategoryLock.lock()
        transactionLock.lock()
        
        defer {
            transactionCategoryLock.unlock()
            transactionLock.unlock()
        }
        
        linkObjectToParentObject(type: Transaction.self, parentType: TransactionCategory.self, managedObjectContext: managedObjectContext, linkedIDs: linkingTransactionCategoryIDs, linkedKey: \Transaction.transactionCategoryID, linkedKeyName: #keyPath(Transaction.transactionCategoryID))
        
        linkingTransactionCategoryIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleProviderResponse(_ providerResponse: APIProviderResponse, managedObjectContext: NSManagedObjectContext) {
        providerLock.lock()
        
        defer {
            providerLock.unlock()
        }
        
        updateObjectWithResponse(type: Provider.self, objectResponse: providerResponse, primaryKey: #keyPath(Provider.providerID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleProvidersResponse(_ providersResponse: [APIProviderResponse], managedObjectContext: NSManagedObjectContext) {
        providerLock.lock()
        
        defer {
            providerLock.unlock()
        }
        
        let filterPredicate = NSPredicate(format: #keyPath(Provider.statusRawValue) + " IN %@", argumentArray: [[Provider.Status.supported.rawValue, Provider.Status.beta.rawValue]])
        
        updateObjectsWithResponse(type: Provider.self, objectsResponse: providersResponse, primaryKey: #keyPath(Provider.providerID), linkedKeys: [], filterPredicate: filterPredicate, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleProviderAccountResponse(_ providerAccountResponse: APIProviderAccountResponse, managedObjectContext: NSManagedObjectContext) {
        providerAccountLock.lock()
        
        defer {
            providerAccountLock.unlock()
        }
        
        updateObjectWithResponse(type: ProviderAccount.self, objectResponse: providerAccountResponse, primaryKey: #keyPath(ProviderAccount.providerAccountID), managedObjectContext: managedObjectContext)
        
        linkingProviderIDs.insert(providerAccountResponse.providerID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleProviderAccountsResponse(_ providerAccountsResponse: [APIProviderAccountResponse], managedObjectContext: NSManagedObjectContext) {
        providerAccountLock.lock()
        
        defer {
            providerAccountLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: ProviderAccount.self, objectsResponse: providerAccountsResponse, primaryKey: #keyPath(ProviderAccount.providerAccountID), linkedKeys: [\ProviderAccount.providerID], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        if let providerIDs = updatedLinkedIDs[\ProviderAccount.providerID] {
            linkingProviderIDs = linkingProviderIDs.union(providerIDs)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleAccountResponse(_ accountResponse: APIAccountResponse, managedObjectContext: NSManagedObjectContext) {
        accountLock.lock()
        
        defer {
            accountLock.unlock()
        }
        
        updateObjectWithResponse(type: Account.self, objectResponse: accountResponse, primaryKey: #keyPath(Account.accountID), managedObjectContext: managedObjectContext)
        
        linkingProviderAccountIDs.insert(accountResponse.providerAccountID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleAccountsResponse(_ accountsResponse: [APIAccountResponse], managedObjectContext: NSManagedObjectContext) {
        accountLock.lock()
        
        defer {
            accountLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: Account.self, objectsResponse: accountsResponse, primaryKey: #keyPath(Account.accountID), linkedKeys: [\Account.providerAccountID], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        if let providerAccountIDs = updatedLinkedIDs[\Account.providerAccountID] {
            linkingProviderAccountIDs = linkingProviderAccountIDs.union(providerAccountIDs)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionResponse(_ transactionResponse: APITransactionResponse, managedObjectContext: NSManagedObjectContext) {
        transactionLock.lock()
        
        defer {
            transactionLock.unlock()
        }
        
        updateObjectWithResponse(type: Transaction.self, objectResponse: transactionResponse, primaryKey: #keyPath(Transaction.transactionID), managedObjectContext: managedObjectContext)
        
        linkingAccountIDs.insert(transactionResponse.accountID)
        linkingMerchantIDs.insert(transactionResponse.merchantID)
        linkingTransactionCategoryIDs.insert(transactionResponse.categoryID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionsResponse(_ transactionsResponse: [APITransactionResponse], from fromDate: Date, to toDate: Date, managedObjectContext: NSManagedObjectContext) {
        let fromDateString = Transaction.transactionDateFormatter.string(from: fromDate)
        let toDateString = Transaction.transactionDateFormatter.string(from: toDate)
        
        let predicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " >= %@ && " + #keyPath(Transaction.transactionDateString) + " <= %@", argumentArray: [fromDateString, toDateString])
        
        handleTransactionsResponse(transactionsResponse, predicate: predicate, managedObjectContext: managedObjectContext)
    }
    
    private func handleTransactionsResponse(_ transactionsResponse: [APITransactionResponse], transactionIDs: [Int64], managedObjectContext: NSManagedObjectContext) {
        let predicate = NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [transactionIDs])
        
        handleTransactionsResponse(transactionsResponse, predicate: predicate, managedObjectContext: managedObjectContext)
    }
    
    private func handleTransactionsResponse(_ transactionsResponse: [APITransactionResponse], predicate: NSPredicate, managedObjectContext: NSManagedObjectContext) {
        transactionLock.lock()
        
        defer {
            transactionLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: Transaction.self, objectsResponse: transactionsResponse, primaryKey: #keyPath(Transaction.transactionID), linkedKeys: [\Transaction.accountID, \Transaction.merchantID, \Transaction.transactionCategoryID], filterPredicate: predicate, managedObjectContext: managedObjectContext)
        
        if let updatedAccountIDs = updatedLinkedIDs[\Transaction.accountID], let updatedMerchantIDs = updatedLinkedIDs[\Transaction.merchantID], let updatedTransactionCategoryIDs = updatedLinkedIDs[\Transaction.transactionCategoryID] {
            linkingAccountIDs = linkingAccountIDs.union(updatedAccountIDs)
            linkingMerchantIDs = linkingMerchantIDs.union(updatedMerchantIDs)
            linkingTransactionCategoryIDs = linkingTransactionCategoryIDs.union(updatedTransactionCategoryIDs)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleMerchantsResponse(_ merchantsResponse: [APIMerchantResponse], managedObjectContext: NSManagedObjectContext) {
        merchantLock.lock()
        
        defer {
            merchantLock.unlock()
        }
        
        updateObjectsWithResponse(type: Merchant.self, objectsResponse: merchantsResponse, primaryKey: #keyPath(Merchant.merchantID), linkedKeys: [], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionCategoriesResponse(_ transactionCategoriesResponse: [APITransactionCategoryResponse], managedObjectContext: NSManagedObjectContext) {
        transactionCategoryLock.lock()
        
        defer {
            transactionCategoryLock.unlock()
        }
        
        updateObjectsWithResponse(type: TransactionCategory.self, objectsResponse: transactionCategoriesResponse, primaryKey: #keyPath(TransactionCategory.transactionCategoryID), linkedKeys: [], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
