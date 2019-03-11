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
    
    /// Notification fired when transactions cache has been updated
    public static let transactionsUpdatedNotification = Notification.Name(rawValue: "FrolloSDK.aggregation.transactionsUpdatedNotification")
    
    internal static let refreshTransactionIDsKey = "FrolloSDKKey.Aggregation.transactionIDs"
    internal static let refreshTransactionsNotification = Notification.Name(rawValue: "FrolloSDK.aggregation.refreshTransactionsNotification")
    
    internal let accountLock = NSLock()
    internal let merchantLock = NSLock()
    internal let providerLock = NSLock()
    internal let providerAccountLock = NSLock()
    internal let transactionLock = NSLock()
    internal let transactionCategoryLock = NSLock()
    
    private let database: Database
    private let service: APIService
    private let transactionBatchSize = 200
    
    private var linkingProviderIDs = Set<Int64>()
    private var linkingProviderAccountIDs = Set<Int64>()
    private var linkingAccountIDs = Set<Int64>()
    private var linkingMerchantIDs = Set<Int64>()
    private var linkingTransactionCategoryIDs = Set<Int64>()
    private var refreshingMerchantIDs = Set<Int64>()
    private var refreshingProviderIDs = Set<Int64>()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
        
        NotificationCenter.default.addObserver(forName: Aggregation.refreshTransactionsNotification, object: nil, queue: .main) { notification in
            guard let transactionIDs = notification.userInfo?[Aggregation.refreshTransactionIDsKey] as? [Int64]
            else {
                return
            }
            
            self.refreshTransactions(transactionIDs: transactionIDs)
        }
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        service.fetchProviders { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProvidersResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        service.fetchProvider(providerID: providerID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.refreshingProviderIDs.remove(providerID)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        service.fetchProviderAccounts { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountsResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        service.fetchProviderAccount(providerAccountID: providerAccountID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        
        service.createProviderAccount(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Delete a provider account from the host
     
     - parameters:
        - providerAccountID: ID of the provider account to be deleted
        - completion: Optional completion handler with optional error if the request fails
    */
    public func deleteProviderAccount(providerAccountID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.deleteProviderAccount(providerAccountID: providerAccountID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedProviderAccount(providerAccountID: providerAccountID)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        
        service.updateProviderAccount(providerAccountID: providerAccountID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        service.fetchAccounts { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountsResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountsToProviderAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        service.fetchAccount(accountID: accountID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountsToProviderAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        let managedObjectContext = database.newBackgroundContext()
        
        guard let account = account(context: managedObjectContext, accountID: accountID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APIAccountUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = account.updateRequest()
        }
        
        service.updateAccount(accountID: accountID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAccountResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkAccountsToProviderAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        refreshNextTransactions(from: fromDate, to: toDate, skip: 0, updatedTransactionIDs: [], completion: completion)
    }
    
    private func refreshNextTransactions(from fromDate: Date, to toDate: Date, skip: Int, updatedTransactionIDs: [Int64], completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchTransactions(from: fromDate, to: toDate, count: transactionBatchSize, skip: skip) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    let updatedIDs = self.handleTransactionsResponse(response, from: fromDate, to: toDate, managedObjectContext: managedObjectContext) + updatedTransactionIDs
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    if response.count >= self.transactionBatchSize {
                        self.refreshNextTransactions(from: fromDate, to: toDate, skip: skip + self.transactionBatchSize, updatedTransactionIDs: updatedIDs, completion: completion)
                    } else {
                        self.removeTransactions(from: fromDate, to: toDate, excludingIDs: updatedIDs, managedObjectContext: managedObjectContext)
                        
                        NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                        
                        DispatchQueue.main.async {
                            completion?(.success)
                        }
                    }
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
        service.fetchTransaction(transactionID: transactionID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        service.fetchTransactions(transactionIDs: transactionIDs) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionsResponse(response, transactionIDs: transactionIDs, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Exclude a transaction from budgets and reports and update on the host
     
     - parameters:
        - transactionID: ID of the transaction to be updated
        - excluded: Exclusion status of the transaction. True will mark a transaction as no longer included in budgets etc
        - excludeAll: Apply exclusion status to all similar transactions
        - completion: Optional completion handler with optional error if the request fails
     */
    public func excludeTransaction(transactionID: Int64, excluded: Bool, excludeAll: Bool, completion: FrolloSDKCompletionHandler? = nil) {
        let managedObjectContext = database.newBackgroundContext()
        
        guard let transaction = transaction(context: managedObjectContext, transactionID: transactionID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APITransactionUpdateRequest!
        
        managedObjectContext.performAndWait {
            transaction.included = !excluded
            
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
            
            request = transaction.updateRequest()
        }
        
        request.includeApplyAll = excludeAll
        
        service.updateTransaction(transactionID: transactionID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Recategorise a transaction and update on the host
     
     - parameters:
        - transactionID: ID of the transaction to be updated
        - transactionCategoryID: The transaction category ID to recategorise the transaction to
        - recategoriseAll: Apply recategorisation to all similar transactions
        - completion: Optional completion handler with optional error if the request fails
     */
    public func recategoriseTransaction(transactionID: Int64, transactionCategoryID: Int64, recategoriseAll: Bool, completion: FrolloSDKCompletionHandler? = nil) {
        let managedObjectContext = database.newBackgroundContext()
        
        guard let transaction = transaction(context: managedObjectContext, transactionID: transactionID),
            let transactionCategory = transactionCategory(context: managedObjectContext, transactionCategoryID: transactionCategoryID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APITransactionUpdateRequest!
        
        managedObjectContext.performAndWait {
            transaction.transactionCategoryID = transactionCategoryID
            transaction.transactionCategory = transactionCategory
            
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
            
            request = transaction.updateRequest()
        }
        
        request.recategoriseAll = recategoriseAll
        
        service.updateTransaction(transactionID: transactionID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a transaction on the host
     
     - parameters:
        - transactionID: ID of the transaction to be updated
        - includeApplyAll: Apply included flag to all similar transactions (Optional)
        - recategoriseAll: Apply recategorisation to all similar transactions (Optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateTransaction(transactionID: Int64, includeApplyAll: Bool? = nil, recategoriseAll: Bool? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        let managedObjectContext = database.newBackgroundContext()
        
        guard let transaction = transaction(context: managedObjectContext, transactionID: transactionID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APITransactionUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = transaction.updateRequest()
        }
        
        request.includeApplyAll = includeApplyAll
        request.recategoriseAll = recategoriseAll
        
        service.updateTransaction(transactionID: transactionID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Transaction summary
     
     Retrieves sum and count of transactions for specified filters
     
     - parameters:
         - fromDate: Start date to fetch transactions from (inclusive)
         - toDate: End date to fetch transactions up to (inclusive)
         - accountIDs: A list of account IDs to fetch associated transactions from
         - transactionIDs: A list of transaction IDs to fetch
         - onlyIncludedAccounts: Only include transactions from accounts not marked as excluded from budget
         - onlyIncludedTransactions: Only include transactions not marked as excluded
         - completion: Completion handler with count and sum of transactions if successful or error if it fails
    */
    public func transactionSummary(from fromDate: Date, to toDate: Date, accountIDs: [Int64]? = nil, transactionIDs: [Int64]? = nil, onlyIncludedAccounts: Bool? = nil, onlyIncludedTransactions: Bool? = nil, completion: @escaping (Result<(count: Int64, sum: Decimal), Error>) -> Void) {
        service.transactionSummary(from: fromDate, to: toDate, accountIDs: accountIDs, transactionIDs: transactionIDs, onlyIncludedAccounts: onlyIncludedAccounts, onlyIncludedTransactions: onlyIncludedTransactions) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    var sum: Decimal = 0
                    
                    if let transactionSum = NSDecimalNumber(string: response.sum) as Decimal? {
                        sum = transactionSum
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success((count: response.count, sum: sum)))
                    }
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        service.fetchTransactionCategories { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionCategoriesResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
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
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func merchantsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Merchant>? {
        return fetchedResultsController(type: Merchant.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all merchants from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
    */
    internal func refreshMerchants(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchMerchants { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantsResponse(response, predicate: nil, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific merchant by ID from the host
     
     - parameters:
        - merchantID: ID of the merchant to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshMerchant(merchantID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchMerchant(merchantID: merchantID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh specific merchants by ID from the host
     
     - parameters:
        - merchantIDs: List of merchant IDs to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshMerchants(merchantIDs: [Int64], completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchMerchants(merchantIDs: merchantIDs) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantsResponse(response, merchantIDs: merchantIDs, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        
        linkingProviderIDs = missingProviderIDs
        
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
        
        let missingMerchantIDs = linkObjectToParentObject(type: Transaction.self, parentType: Merchant.self, managedObjectContext: managedObjectContext, linkedIDs: linkingMerchantIDs, linkedKey: \Transaction.merchantID, linkedKeyName: #keyPath(Transaction.merchantID))
        
        linkingMerchantIDs = missingMerchantIDs
        
        let merchantIDs = missingMerchantIDs.subtracting(refreshingMerchantIDs)
        
        if !merchantIDs.isEmpty {
            refreshingMerchantIDs = refreshingMerchantIDs.union(merchantIDs)
            refreshMerchants(merchantIDs: Array(merchantIDs))
        }
        
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
    
    private func handleTransactionsResponse(_ transactionsResponse: [APITransactionResponse], from fromDate: Date, to toDate: Date, managedObjectContext: NSManagedObjectContext) -> [Int64] {
        // Sort by ID
        let sortedObjectResponses = transactionsResponse.sorted(by: { (responseA: APITransactionResponse, responseB: APITransactionResponse) -> Bool in
            responseB.id > responseA.id
        })
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        
        var linkedAccountIDs = Set<Int64>()
        var linkedMerchantIDs = Set<Int64>()
        var linkedTransactionCategoryIDs = Set<Int64>()
        
        managedObjectContext.performAndWait {
            // Fetch existing objects for updating
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            
            let fromDateString = Transaction.transactionDateFormatter.string(from: fromDate)
            let toDateString = Transaction.transactionDateFormatter.string(from: toDate)
            let filterPredicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " >= %@ && " + #keyPath(Transaction.transactionDateString) + " <= %@", argumentArray: [fromDateString, toDateString])
            let transactionIDPredicate = NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [objectIDs])
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, transactionIDPredicate])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Transaction.transactionID), ascending: true)]
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for objectResponse in sortedObjectResponses {
                    var object: Transaction
                    
                    if index < existingObjects.count, existingObjects[index].primaryID == objectResponse.id {
                        object = existingObjects[index]
                        index += 1
                    } else {
                        object = Transaction(context: managedObjectContext)
                    }
                    
                    object.update(response: objectResponse, context: managedObjectContext)
                    
                    linkedAccountIDs.insert(object.accountID)
                    linkedMerchantIDs.insert(object.merchantID)
                    linkedTransactionCategoryIDs.insert(object.transactionCategoryID)
                }
            } catch let fetchError {
                Log.error(fetchError.localizedDescription)
            }
        }
        
        linkingAccountIDs = linkingAccountIDs.union(linkedAccountIDs)
        linkingMerchantIDs = linkingMerchantIDs.union(linkedMerchantIDs)
        linkingTransactionCategoryIDs = linkingTransactionCategoryIDs.union(linkedTransactionCategoryIDs)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return objectIDs
    }
    
    private func removeTransactions(from fromDate: Date, to toDate: Date, excludingIDs: [Int64], managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.performAndWait {
            // Fetch and delete any leftovers
            let deleteRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            
            let fromDateString = Transaction.transactionDateFormatter.string(from: fromDate)
            let toDateString = Transaction.transactionDateFormatter.string(from: toDate)
            let filterPredicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " >= %@ && " + #keyPath(Transaction.transactionDateString) + " <= %@", argumentArray: [fromDateString, toDateString])
            let transactionIDPredicate = NSPredicate(format: "NOT " + #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [excludingIDs])
            deleteRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, transactionIDPredicate])
            
            do {
                let deleteObjects = try managedObjectContext.fetch(deleteRequest)
                
                for deleteObject in deleteObjects {
                    managedObjectContext.delete(deleteObject)
                }
            } catch let fetchError {
                Log.error(fetchError.localizedDescription)
            }
            
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionsResponse(_ transactionsResponse: [APITransactionResponse], transactionIDs: [Int64], managedObjectContext: NSManagedObjectContext) {
        let predicate = NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [transactionIDs])
        
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
    
    private func handleMerchantResponse(_ merchantResponse: APIMerchantResponse, managedObjectContext: NSManagedObjectContext) {
        merchantLock.lock()
        
        defer {
            merchantLock.unlock()
        }
        
        updateObjectWithResponse(type: Merchant.self, objectResponse: merchantResponse, primaryKey: #keyPath(Merchant.merchantID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleMerchantsResponse(_ merchantsResponse: [APIMerchantResponse], merchantIDs: [Int64], managedObjectContext: NSManagedObjectContext) {
        let predicate = NSPredicate(format: #keyPath(Merchant.merchantID) + " IN %@", argumentArray: [merchantIDs])
        
        handleMerchantsResponse(merchantsResponse, predicate: predicate, managedObjectContext: managedObjectContext)
    }
    
    private func handleMerchantsResponse(_ merchantsResponse: [APIMerchantResponse], predicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) {
        merchantLock.lock()
        
        defer {
            merchantLock.unlock()
        }
        
        updateObjectsWithResponse(type: Merchant.self, objectsResponse: merchantsResponse, primaryKey: #keyPath(Merchant.merchantID), linkedKeys: [], filterPredicate: predicate, managedObjectContext: managedObjectContext)
        
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
    
    private func removeCachedProviderAccount(providerAccountID: Int64) {
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "providerAccountID == %ld", providerAccountID)
            
            do {
                let fetchedProviderAccounts = try managedObjectContext.fetch(fetchRequest)
                
                if let providerAccount = fetchedProviderAccounts.first {
                    managedObjectContext.performAndWait {
                        managedObjectContext.delete(providerAccount)
                        
                        do {
                            try managedObjectContext.save()
                        } catch {
                            Log.error(error.localizedDescription)
                        }
                    }
                }
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
