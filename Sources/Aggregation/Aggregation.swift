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

import CoreData
import Foundation

/// Manages all aggregation data including accounts, transactions, categories and merchants
public class Aggregation: CachedObjects, ResponseHandler {
    
    /**
     Contains the possible cases to order Aggregation entities
     */
    public enum OrderType: String {
        /// Ascending order
        case asc
        /// Descending order
        case desc
    }
    
    /**
     Contains the possible cases to sort Aggregation entities
     */
    public enum SortType: String {
        /// Sort by name
        case name
        /// Sort by relevance
        case relevance
    }
    
    /// Merchant search response
    public typealias MerchantSearchResponse = (data: [MerchantSearchResult], before: String?, after: String?)
    
    /// Result with information of transaction Pagination cursors and total count, ids and dates
    public typealias TransactionPaginationInfo = (before: String?, after: String?, total: Int?, beforeID: Int64?, afterID: Int64?, beforeDate: String?, afterDate: String?)
    
    /// Transaction Completion Handler with TransactionPaginationInfo and optional error if an issue occurs
    public typealias TransactionPaginatedCompletionHandler = (Result<TransactionPaginationInfo, Error>) -> Void
    
    /**
     Tuple of tagname (String) and apply to all similar transactions (Bool)
     */
    public typealias tagApplyAllPairs = (String, Bool)
    
    /// Notification fired when accounts cache has been updated
    public static let accountsUpdatedNotification = Notification.Name("FrolloSDK.aggregation.accountsUpdatedNotification")
    
    /// Notification fired when providers cache has been updated
    public static let providersUpdatedNotification = Notification.Name("FrolloSDK.aggregation.providersUpdatedNotification")
    
    /// Notification fired when provider accounts cache has been updated
    public static let providerAccountsUpdatedNotification = Notification.Name("FrolloSDK.aggregation.providerAccountsUpdatedNotification")
    
    /// Notification fired when merchants cache has been updated
    public static let merchantsUpdatedNotification = Notification.Name("FrolloSDK.aggregation.merchantsUpdatedNotification")
    
    /// Notification fired when transactions cache has been updated
    public static let transactionsUpdatedNotification = Notification.Name("FrolloSDK.aggregation.transactionsUpdatedNotification")
    
    /// Notification fired when transaction categories cache has been updated
    public static let transactionCategoriesUpdatedNotification = Notification.Name("FrolloSDK.aggregation.transactionCategoriesUpdatedNotification")
    
    /// Notification fired when silent push notification recieved to update transactions
    public static let refreshTransactionsNotification = Notification.Name("FrolloSDK.aggregation.refreshTransactionsNotification")
    
    internal static let refreshTransactionIDsKey = "FrolloSDKKey.Aggregation.transactionIDs"
    
    internal let accountLock = NSLock()
    internal let merchantLock = NSLock()
    internal let providerLock = NSLock()
    internal let providerAccountLock = NSLock()
    internal let transactionLock = NSLock()
    internal let transactionCategoryLock = NSLock()
    internal let userTagsLock = NSLock()
    
    private let database: Database
    private let service: APIService
    private let merchantBatchSize = 500
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
        - status: Filter by status of the provider support (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Provider` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func providers(context: NSManagedObjectContext,
                          status: Provider.Status? = nil,
                          filteredBy predicate: NSPredicate? = nil,
                          sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Provider.providerID), ascending: true)],
                          limit: Int? = nil) -> [Provider]? {
        var predicates = [NSPredicate]()
        
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Provider.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Provider.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Providers from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - status: Filter by status of the provider support (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Provider` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func providersFetchedResultsController(context: NSManagedObjectContext,
                                                  status: Provider.Status? = nil,
                                                  filteredBy predicate: NSPredicate? = nil,
                                                  sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Provider.providerID), ascending: true)],
                                                  limit: Int? = nil) -> NSFetchedResultsController<Provider>? {
        var predicates = [NSPredicate]()
        
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Provider.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Provider.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
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
                    
                    NotificationCenter.default.post(name: Aggregation.providersUpdatedNotification, object: self)
                    
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
                    
                    NotificationCenter.default.post(name: Aggregation.providersUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Submits consent form for a specific provider
     
     - parameters:
        - consent: The form that will be submitted
        - completion: The block that will be executed when the submit request is complete
     */
    public func submitCDRConsent(consent: CDRConsentForm.Post, completion: ((Result<CDRConsent, Error>) -> Void)?) {
        service.submitCDRConsent(request: consent.apiRequest) { result in
            switch result {
                case .success(let response):
                    completion?(.success(response.consent))
                case .failure(let error):
                    completion?(.failure(error))
            }
        }
    }
    
    /**
     Withdraws a consent deleting all its data
     
     - parameters:
        - consent: The form that will be submitted
        - completion: The block that will be executed when the submit request is complete
     */
    public func withdrawCDRConsent(id: Int64, completion: ((Result<CDRConsent, Error>) -> Void)?) {
        let request = APICDRConsentUpdateRequest(status: .withdrawn, deleteRedundantData: true)
        service.updateCDRConsent(id: id, request: request) { result in
            switch result {
                case .success(let response):
                    completion?(.success(response.consent))
                case .failure(let error):
                    completion?(.failure(error))
            }
        }
    }
    
    /**
     Fetch Open banking consent by ID from the backend
     
     - parameters:
        - id: The ID of the consent
        - completion: The block that will be executed when the fetch request is complete
     */
    public func fetchCDRConsent(id: Int64, completion: ((Result<CDRConsent, Error>) -> Void)?) {
        service.fetchCDRConsent(id: id) { result in
            switch result {
                case .success(let response):
                    completion?(.success(response.consent))
                case .failure(let error):
                    completion?(.failure(error))
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
        - refreshStatus: Filter by the current refresh status of the provider account (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `ProviderAccount` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerAccountID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func providerAccounts(context: NSManagedObjectContext,
                                 refreshStatus: AccountRefreshStatus? = nil,
                                 filteredBy predicate: NSPredicate? = nil,
                                 sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ProviderAccount.providerAccountID), ascending: true)],
                                 limit: Int? = nil) -> [ProviderAccount]? {
        var predicates = [NSPredicate]()
        
        if let filterRefreshStatus = refreshStatus {
            predicates.append(NSPredicate(format: #keyPath(ProviderAccount.refreshStatusRawValue) + " == %@", argumentArray: [filterRefreshStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: ProviderAccount.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Provider Accounts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - refreshStatus: Filter by the current refresh status of the provider account (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `ProviderAccount` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to providerAccountID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func providerAccountsFetchedResultsController(context: NSManagedObjectContext,
                                                         refreshStatus: AccountRefreshStatus? = nil,
                                                         filteredBy predicate: NSPredicate? = nil,
                                                         sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(ProviderAccount.providerAccountID), ascending: true)],
                                                         limit: Int? = nil) -> NSFetchedResultsController<ProviderAccount>? {
        var predicates = [NSPredicate]()
        
        if let filterRefreshStatus = refreshStatus {
            predicates.append(NSPredicate(format: #keyPath(ProviderAccount.refreshStatusRawValue) + " == %@", argumentArray: [filterRefreshStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: ProviderAccount.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
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
                    
                    self.handleProviderAccountsResponse(response, predicate: nil, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.providerAccountsUpdatedNotification, object: self)
                    
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
                    
                    NotificationCenter.default.post(name: Aggregation.providerAccountsUpdatedNotification, object: self)
                    
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
        - completion: Optional completion handler which returns the provider account id that was created if it was successful, or and error if it was a failure
     */
    public func createProviderAccount(providerID: Int64, loginForm: ProviderLoginForm, completion: ((Result<Int64, Error>) -> Void)? = nil) {
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
                    
                    NotificationCenter.default.post(name: Aggregation.providerAccountsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success(response.id))
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
                    
                    NotificationCenter.default.post(name: Aggregation.providerAccountsUpdatedNotification, object: self)
                    
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
                    
                    NotificationCenter.default.post(name: Aggregation.providerAccountsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Fetches the latest account data from the aggregation partner.
     
     - parameters:
        - providerAccountIDs: Array of IDs of the provider account separated by comma(,)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func syncProviderAccounts(providerAccountIDs: [Int64], completion: FrolloSDKCompletionHandler? = nil) {
        service.syncProviderAccounts(providerAccountIDs: providerAccountIDs) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleProviderAccountsResponse(response, providerAccountIDs: providerAccountIDs, managedObjectContext: managedObjectContext)
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.providerAccountsUpdatedNotification, object: self)
                    
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
        - accountStatus: Filter by the account status (Optional)
        - accountSubType: Filter by the sub type of account (Optional)
        - accountType: Filter by the type of the account (Optional)
        - classification: Filter by the classification of the account (Optional)
        - favourite: Filter by favourited accounts (Optional)
        - hidden: Filter by hidden accounts (Optional)
        - included: Filter by accounts included in the budget (Optional)
        - refreshStatus: Filter by the current refresh status of the provider account (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Account` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to accountID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func accounts(context: NSManagedObjectContext,
                         accountStatus: Account.AccountStatus? = nil,
                         accountSubType: Account.AccountSubType? = nil,
                         accountType: Account.AccountType? = nil,
                         classification: Account.Classification? = nil,
                         favourite: Bool? = nil,
                         hidden: Bool? = nil,
                         included: Bool? = nil,
                         refreshStatus: AccountRefreshStatus? = nil,
                         filteredBy predicate: NSPredicate? = nil,
                         sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Account.accountID), ascending: true)],
                         limit: Int? = nil) -> [Account]? {
        var predicates = [NSPredicate]()
        
        if let filterAccountStatus = accountStatus {
            predicates.append(NSPredicate(format: #keyPath(Account.accountStatusRawValue) + " == %@", argumentArray: [filterAccountStatus.rawValue]))
        }
        
        if let filterAccountSubType = accountSubType {
            predicates.append(NSPredicate(format: #keyPath(Account.accountSubTypeRawValue) + " == %@", argumentArray: [filterAccountSubType.rawValue]))
        }
        
        if let filterAccountType = accountType {
            predicates.append(NSPredicate(format: #keyPath(Account.accountTypeRawValue) + " == %@", argumentArray: [filterAccountType.rawValue]))
        }
        
        if let filterClassification = classification {
            predicates.append(NSPredicate(format: #keyPath(Account.classificationRawValue) + " == %@", argumentArray: [filterClassification.rawValue]))
        }
        
        if let filterFavourite = favourite {
            predicates.append(NSPredicate(format: #keyPath(Account.favourite) + " == %ld", argumentArray: [filterFavourite]))
        }
        
        if let filterHidden = hidden {
            predicates.append(NSPredicate(format: #keyPath(Account.hidden) + " == %ld", argumentArray: [filterHidden]))
        }
        
        if let filterIncluded = included {
            predicates.append(NSPredicate(format: #keyPath(Account.included) + " == %ld", argumentArray: [filterIncluded]))
        }
        
        if let filterRefreshStatus = refreshStatus {
            predicates.append(NSPredicate(format: #keyPath(Account.refreshStatusRawValue) + " == %@", argumentArray: [filterRefreshStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Account.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Accounts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - accountStatus: Filter by the account status (Optional)
        - accountSubType: Filter by the sub type of account (Optional)
        - accountType: Filter by the type of the account (Optional)
        - classification: Filter by the classification of the account (Optional)
        - favourite: Filter by favourited accounts (Optional)
        - hidden: Filter by hidden accounts (Optional)
        - included: Filter by accounts included in the budget (Optional)
        - refreshStatus: Filter by the current refresh status of the provider account (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Account` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to accountID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func accountsFetchedResultsController(context: NSManagedObjectContext,
                                                 accountStatus: Account.AccountStatus? = nil,
                                                 accountSubType: Account.AccountSubType? = nil,
                                                 accountType: Account.AccountType? = nil,
                                                 classification: Account.Classification? = nil,
                                                 favourite: Bool? = nil,
                                                 hidden: Bool? = nil,
                                                 included: Bool? = nil,
                                                 refreshStatus: AccountRefreshStatus? = nil,
                                                 filteredBy predicate: NSPredicate? = nil,
                                                 sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Account.accountID), ascending: true)],
                                                 limit: Int? = nil) -> NSFetchedResultsController<Account>? {
        var predicates = [NSPredicate]()
        
        if let filterAccountStatus = accountStatus {
            predicates.append(NSPredicate(format: #keyPath(Account.accountStatusRawValue) + " == %@", argumentArray: [filterAccountStatus.rawValue]))
        }
        
        if let filterAccountSubType = accountSubType {
            predicates.append(NSPredicate(format: #keyPath(Account.accountSubTypeRawValue) + " == %@", argumentArray: [filterAccountSubType.rawValue]))
        }
        
        if let filterAccountType = accountType {
            predicates.append(NSPredicate(format: #keyPath(Account.accountTypeRawValue) + " == %@", argumentArray: [filterAccountType.rawValue]))
        }
        
        if let filterClassification = classification {
            predicates.append(NSPredicate(format: #keyPath(Account.classificationRawValue) + " == %@", argumentArray: [filterClassification.rawValue]))
        }
        
        if let filterFavourite = favourite {
            predicates.append(NSPredicate(format: #keyPath(Account.favourite) + " == %ld", argumentArray: [filterFavourite]))
        }
        
        if let filterHidden = hidden {
            predicates.append(NSPredicate(format: #keyPath(Account.hidden) + " == %ld", argumentArray: [filterHidden]))
        }
        
        if let filterIncluded = included {
            predicates.append(NSPredicate(format: #keyPath(Account.included) + " == %ld", argumentArray: [filterIncluded]))
        }
        
        if let filterRefreshStatus = refreshStatus {
            predicates.append(NSPredicate(format: #keyPath(Account.refreshStatusRawValue) + " == %@", argumentArray: [filterRefreshStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Account.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
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
                    
                    NotificationCenter.default.post(name: Aggregation.accountsUpdatedNotification, object: self)
                    
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
                    
                    NotificationCenter.default.post(name: Aggregation.accountsUpdatedNotification, object: self)
                    
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
                    
                    NotificationCenter.default.post(name: Aggregation.accountsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Fetches products list form for a specific account
     
     - parameters:
        - accountID: Account ID of the Account to fetch products
        - completion: The block that will be executed when the submit request is complete
     */
    public func fetchProducts(accountID: Int64, completion: ((Result<[CDRProduct], Error>) -> Void)?) {
        
        service.fetchProducts(accountID: accountID) { result in
            switch result {
                case .success(let response):
                    completion?(.success(response))
                case .failure(let error):
                    completion?(.failure(error))
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
        - baseType: Filter by base type of the transaction (Optional)
        - budgetCategory: Filter by budget category of the transaction (Optional)
        - status: Filter by the status of the transaction (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Transaction` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func transactions(context: NSManagedObjectContext,
                             baseType: Transaction.BaseType? = nil,
                             budgetCategory: BudgetCategory? = nil,
                             status: Transaction.Status? = nil,
                             filteredBy predicate: NSPredicate? = nil,
                             sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Transaction.transactionID), ascending: true)],
                             limit: Int? = nil) -> [Transaction]? {
        var predicates = [NSPredicate]()
        
        if let filterBaseType = baseType {
            predicates.append(NSPredicate(format: #keyPath(Transaction.baseTypeRawValue) + " == %@", argumentArray: [filterBaseType.rawValue]))
        }
        
        if let filterBudgetCategory = budgetCategory {
            predicates.append(NSPredicate(format: #keyPath(Transaction.budgetCategoryRawValue) + " == %@", argumentArray: [filterBudgetCategory.rawValue]))
        }
        
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Transaction.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Transaction.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch transactions from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - transactionFilter: `TransactionFilter` object to apply filters (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func transactions(context: NSManagedObjectContext,
                             transactionFilter: TransactionFilter? = nil,
                             sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Transaction.transactionID), ascending: true)],
                             limit: Int? = nil) -> [Transaction]? {
        var predicates = [NSPredicate]()
        
        if let filterPredicates = transactionFilter?.filterPredicates {
            predicates.append(contentsOf: filterPredicates)
        }
        
        return cachedObjects(type: Transaction.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of transactions from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - baseType: Filter by base type of the transaction (Optional)
        - budgetCategory: Filter by budget category of the transaction (Optional)
        - status: Filter by the status of the transaction (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Transaction` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
        - sectionNameKeyPath: Section Name to group transactions sections (Optional)
     */
    public func transactionsFetchedResultsController(context: NSManagedObjectContext,
                                                     baseType: Transaction.BaseType? = nil,
                                                     budgetCategory: BudgetCategory? = nil,
                                                     status: Transaction.Status? = nil,
                                                     filteredBy predicate: NSPredicate? = nil,
                                                     sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Transaction.transactionID), ascending: true)], batchSize: Int? = nil,
                                                     limit: Int? = nil, sectionNameKeypath: String? = nil) -> NSFetchedResultsController<Transaction>? {
        var predicates = [NSPredicate]()
        
        if let filterBaseType = baseType {
            predicates.append(NSPredicate(format: #keyPath(Transaction.baseTypeRawValue) + " == %@", argumentArray: [filterBaseType.rawValue]))
        }
        
        if let filterBudgetCategory = budgetCategory {
            predicates.append(NSPredicate(format: #keyPath(Transaction.budgetCategoryRawValue) + " == %@", argumentArray: [filterBudgetCategory.rawValue]))
        }
        
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Transaction.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Transaction.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, batchSize: batchSize, limit: limit, sectionNameKeypath: sectionNameKeypath)
    }
    
    /**
     Refresh transactions from from the host
     
     - parameters:
         - transactionFilter: `TransactionFilter` object to filter transactions
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransactions(transactionFilter: TransactionFilter? = nil, completion: TransactionPaginatedCompletionHandler? = nil) {
        service.fetchTransactions(transactionFilter: transactionFilter) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleTransactionsResponse(transactionsResponse: response, transactionFilter: transactionFilter, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    let firstTransaction = response.data.elements.first
                    let lastTransaction = response.data.elements.last
                    
                    DispatchQueue.main.async {
                        completion?(.success(TransactionPaginationInfo(before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, total: response.paging?.total, beforeID: firstTransaction?.id, afterID: lastTransaction?.id, beforeDate: firstTransaction?.transactionDate, afterDate: lastTransaction?.transactionDate)))
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
        
        let transactionFilter = TransactionFilter(transactionIDs: transactionIDs)
        refreshNextTransactions(transactionFilter: transactionFilter) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                    
                case .success:
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     A convenience method that must refresh transactions between two dates iteratively.
     
     - parameters:
        - fromDate: Start date to fetch transactions. Optional; defaults to two months back from today date
        - toDate: End date to fetch transactions. Optional; defaults to today date
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshTransactionsByDate(fromDate: Date? = nil, toDate: Date? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        var startDate: String
        var endDate: String
        
        if let fromDate = fromDate {
            startDate = Transaction.transactionDateFormatter.string(from: fromDate)
        } else {
            startDate = Transaction.transactionDateFormatter.string(from: Date().withAddingValue(-2, to: .month) ?? Date())
        }
        
        if let toDate = toDate {
            endDate = Transaction.transactionDateFormatter.string(from: toDate)
        } else {
            endDate = Transaction.transactionDateFormatter.string(from: Date())
        }
        
        let transactionFilter = TransactionFilter(fromDate: startDate, toDate: endDate)
        
        refreshNextTransactions(transactionFilter: transactionFilter) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                    
                case .success:
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    private func refreshNextTransactions(transactionFilter: TransactionFilter, completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        
        refreshTransactions(transactionFilter: transactionFilter) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                    
                case .success(let before, let after, let total, _, _, _, _):
                    
                    if after == nil {
                        DispatchQueue.main.async {
                            completion?(.success(PaginationInfo(before: before, after: after, total: total)))
                        }
                    } else {
                        var updatedTransactionFilter = transactionFilter
                        updatedTransactionFilter.after = after
                        self.refreshNextTransactions(transactionFilter: updatedTransactionFilter, completion: completion)
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
        - budgetCategoryApplyAll: Apply budget category to all similar transactions (Optional)
        - includeApplyAll: Apply included flag to all similar transactions (Optional)
        - recategoriseAll: Apply recategorisation to all similar transactions (Optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateTransaction(transactionID: Int64, budgetCategoryApplyAll: Bool? = nil, includeApplyAll: Bool? = nil, recategoriseAll: Bool? = nil, completion: FrolloSDKCompletionHandler? = nil) {
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
        
        request.budgetApplyAll = budgetCategoryApplyAll
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
     Transaction search
     
     Search for transactions from the server. Transactions will be cached and a list of matching transaction IDs returned.
     Search results are paginated and retrieving the full list of more than 200 will require incrementing the `page` parameter.
     
     Example:
         // Fetch results 201-400
         transactionSearch(searchTerm: "supermarket", page: 1)
     
     The search term will match the following fields on a transaction:
     
     * `originalDescription`
     * `simpleDescription`
     * `userDescription`
     * `amount`
     * `Merchant.name`
     * `TransactionCategory.name`
     
     Magic search terms can also be used where the following will match specific types or properties rather than the fields above.
     
     * excluded - Only transactions where `included` is false
     * pending - Only transactions where `status` is pending
     * income - Budget category is income
     * living - Budget category is living
     * lifestyle - Budget category is lifestyle
     * goals - Budget category is goals
     
     - parameters:
         - searchTerm: Search term to match, either text, amount or magic term
         - page: Page to start search from. Defaults to 0
         - fromDate: Date to start search from (Optional)
         - toDate: Date to search up to (Optional)
         - accountIDs: A list of account IDs to restrict search to
         - onlyIncludedAccounts: Only return results from accounts included in the budget
     */
    public func transactionSearch(searchTerm: String, page: Int = 0, from fromDate: Date? = nil, to toDate: Date? = nil, accountIDs: [Int64]? = nil, onlyIncludedAccounts: Bool? = nil, completion: @escaping (Result<[Int64], Error>) -> Void) {
        guard !searchTerm.isEmpty
        else {
            let error = DataError(type: .api, subType: .invalidData)
            
            Log.debug("Search term is empty")
            
            completion(.failure(error))
            return
        }
        
        let offset = transactionBatchSize * page
        
        service.transactionSearch(searchTerm: searchTerm, count: transactionBatchSize, skip: offset, from: fromDate, to: toDate, accountIDs: accountIDs, onlyIncludedAccounts: onlyIncludedAccounts) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    let transactionIDs = response.map { $0.id }
                    
                    self.handleTransactionsResponse(response, transactionIDs: transactionIDs, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkTransactionsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.transactionsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion(.success(transactionIDs))
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
        - defaultBudgetCategory: Filter by the default budget category associated with the transaction category (Optional)
        - type: Filter by type of category (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `TransactionCategory` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionCategoryID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func transactionCategories(context: NSManagedObjectContext,
                                      defaultBudgetCategory: BudgetCategory? = nil,
                                      type: TransactionCategory.CategoryType? = nil,
                                      filteredBy predicate: NSPredicate? = nil,
                                      sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(TransactionCategory.transactionCategoryID), ascending: true)],
                                      limit: Int? = nil) -> [TransactionCategory]? {
        var predicates = [NSPredicate]()
        
        if let filterBudgetCategory = defaultBudgetCategory {
            predicates.append(NSPredicate(format: #keyPath(TransactionCategory.defaultBudgetCategoryRawValue) + " == %@", argumentArray: [filterBudgetCategory.rawValue]))
        }
        
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(TransactionCategory.categoryTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: TransactionCategory.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of transaction categories from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `TransactionCategory` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to transactionCategoryID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func transactionCategoriesFetchedResultsController(context: NSManagedObjectContext,
                                                              defaultBudgetCategory: BudgetCategory? = nil,
                                                              type: TransactionCategory.CategoryType? = nil,
                                                              filteredBy predicate: NSPredicate? = nil,
                                                              sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(TransactionCategory.transactionCategoryID), ascending: true)],
                                                              limit: Int? = nil) -> NSFetchedResultsController<TransactionCategory>? {
        var predicates = [NSPredicate]()
        
        if let filterBudgetCategory = defaultBudgetCategory {
            predicates.append(NSPredicate(format: #keyPath(TransactionCategory.defaultBudgetCategoryRawValue) + " == %@", argumentArray: [filterBudgetCategory.rawValue]))
        }
        
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(TransactionCategory.categoryTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: TransactionCategory.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
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
                    
                    NotificationCenter.default.post(name: Aggregation.transactionCategoriesUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Transaction Tags
    
    /**
     Gets all suggestion tags for transactions. Tags can be filtered, sorted and ordered based on the parameters provided.
     - parameters:
        - searchTerm: The search term to filter the tags on
        - sort: The field to sort the tags on
        - order: Specifies the type of order for the tags
        - completion: The completion block that will be executed when there is a response from the server. The result will contain either the array of suggested tags, or an error if the request fails
     */
    
    public func transactionSuggestedTags(searchTerm: String, sort: SortType = .name, order: OrderType = .asc, completion: @escaping (Result<[SuggestedTag], Error>) -> Void) {
        
        service.fetchTransactionSuggestedTags(searchTerm: searchTerm, sort: sort, order: order) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    let tags = response.map(SuggestedTag.init)
                    
                    DispatchQueue.main.async {
                        completion(.success(tags))
                    }
                    
            }
        }
    }
    
    /**
     Gets all cached user tags for transactions.
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - filteredBy: Predicate of properties to match for fetching. See `Tag` for properties (Optional)
     - sortedBy: Array of sort descriptors to sort the results by (Optional). By default sorts by tag name; ascending.
     - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func transactionUserTags(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil,
                                    sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)], limit: Int? = nil) -> [Tag]? {
        
        return cachedObjects(type: Tag.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refreshes the transactions in the database.
     - parameter completion: The completion block that will be executed after the response from the server. The result will be empty with either success, or failure with an error.
     */
    public func refreshTransactionUserTags(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchTransactionUserTags { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let unsortedApiData):
                    let managedObjectContext = self.database.newBackgroundContext()
                    self.handleTransactionsUserTags(unsortedApiData, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
                    
            }
        }
    }
    
    /**
     Fetched results controller of Tags from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - filteredBy: Predicate of properties to match for fetching. See `Tag` for properties (Optional)
     - sortedBy: Array of sort descriptors to sort the results by. Defaults to name ascending (Optional)
     */
    public func transactionUserTagsFetchedResultsController(context: NSManagedObjectContext,
                                                            filteredBy predicate: NSPredicate? = nil,
                                                            sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]) -> NSFetchedResultsController<Tag>? {
        var predicates = [NSPredicate]()
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Tag.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: nil)
    }
    
    /**
     Add a tag or list of tags from a transaction
     
     - parameters:
     - transactionID: Transaction ID of the Transaction whose tag is added
     - tagApplyAllPairs: Array of tuple tagApplyAllPairs
     */
    
    public func addTagToTransaction(transactionID: Int64, tagApplyAllPairs: [tagApplyAllPairs], completion: FrolloSDKCompletionHandler? = nil) {
        
        let requestArray = tagApplyAllPairs.map { (tagName, applyAll) -> APITagUpdateRequest in
            APITagUpdateRequest(applyToAll: applyAll, name: tagName)
        }
        
        service.updateTags(transactionID: transactionID, method: .post, requestArray: requestArray, completion: { result in
            
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                    
                case .success:
                    let managedObjectContext = self.database.newBackgroundContext()
                    self.handleUpdateTagsResponse(requestArray, transactionID: transactionID, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        })
    }
    
    /**
     Remove a tag or list of tags from a transaction
     
     - parameters:
     - transactionID: Transaction ID of the Transaction whose tag is removed
     - tagApplyAllPairs: Array of Tuple of 'Tag name'(String) and 'Apply to all'(Bool) flag
     */
    
    public func removeTagFromTransaction(transactionID: Int64, tagApplyAllPairs: [(String, Bool)], completion: FrolloSDKCompletionHandler? = nil) {
        
        var requestArray = [APITagUpdateRequest]()
        for tagApplyAllPair in tagApplyAllPairs {
            requestArray.append(APITagUpdateRequest(applyToAll: tagApplyAllPair.1, name: tagApplyAllPair.0))
        }
        
        service.updateTags(transactionID: transactionID, method: .delete, requestArray: requestArray, completion: { result in
            
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                    
                case .success:
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleUpdateTagsResponse(requestArray, isAdd: false, transactionID: transactionID, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        })
    }
    
    /**
     List of tags for a transaction
     
     - parameters:
     - transactionID: Transaction ID of the Transaction whose tags are to be listed
     */
    
    public func listAllTagsForTransaction(transactionID: Int64, completion: @escaping (Result<[String], Error>) -> Void) {
        
        service.listTagsForTransactrion(transactionID: transactionID, completion: { result in
            
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    
                case .success(let apiResponse):
                    
                    DispatchQueue.main.async {
                        let tagsArray = apiResponse.map { $0.name }
                        completion(.success(tagsArray))
                    }
            }
        })
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
        - type: Filter merchants by the type (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Merchant` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to merchantID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func merchants(context: NSManagedObjectContext,
                          type: Merchant.MerchantType? = nil,
                          filteredBy predicate: NSPredicate? = nil,
                          sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)],
                          limit: Int? = nil) -> [Merchant]? {
        var predicates = [NSPredicate]()
        
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(Merchant.merchantTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Merchant.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of merchants from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - type: Filter merchants by the type (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Merchant` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to merchantID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func merchantsFetchedResultsController(context: NSManagedObjectContext,
                                                  type: Merchant.MerchantType? = nil,
                                                  filteredBy predicate: NSPredicate? = nil,
                                                  sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)],
                                                  limit: Int? = nil) -> NSFetchedResultsController<Merchant>? {
        var predicates = [NSPredicate]()
        
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(Merchant.merchantTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Merchant.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
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
                    
                    NotificationCenter.default.post(name: Aggregation.merchantsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh all merchants from the host.
     
     - parameters:
        - before: Merchant ID to fetch before this merchant (optional)
        - after: Merchant ID to fetch upto this merchant (optional)
        - size: Batch size of merchants to returned by API (optional); defaults to 500
        - completion: Optional completion handler with optional error if the request fails
     */
    internal func refreshMerchants(before: String? = nil, after: String? = nil, size: Int? = 500, completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        service.fetchMerchants(before: before, after: after, size: size) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantsResponse(response.data.elements, before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.merchantsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfo(response.paging?.cursors?.before, response.paging?.cursors?.after, response.paging?.total)))
                    }
            }
        }
    }
    
    /**
     Refresh specific merchants by ID from the host
     
     - parameters:
        - merchantIDs: List of merchant IDs to fetch
        - before: Merchant ID to fetch before this merchant (optional)
        - after: Merchant ID to fetch upto this merchant (optional)
        - size: Batch size of merchants to returned by API (optional); defaults to 500
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshMerchantsWithCompletionHandler(merchantIDs: [Int64], before: Int64? = nil, after: Int64? = nil, size: Int? = 500, completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        service.fetchMerchants(merchantIDs: merchantIDs, after: after, before: before, size: size) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantsResponse(response.data.elements, merchantIDs: response.data.elements.map { $0.id }, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.merchantsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfo(response.paging?.cursors?.before, response.paging?.cursors?.after, response.paging?.total)))
                    }
            }
        }
    }
    
    /**
     Iteratively refresh specific merchants by ID from the host
     
     - parameters:
        - batchSize: Size of the batch for each response (optional); defaults to 500
        - merchantIDs: List of merchant IDs to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshMerchants(batchSize: Int? = 500, merchantIDs: [Int64], completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        
        var after: Int64?
        
        service.fetchMerchants(merchantIDs: merchantIDs, after: after, size: batchSize) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMerchantsResponse(response.data.elements, merchantIDs: response.data.elements.map { $0.id }, managedObjectContext: managedObjectContext)
                    
                    self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Aggregation.merchantsUpdatedNotification, object: self)
                    
                    if let nextCursor = response.paging?.cursors?.after, let nextMerchantID = Int64(nextCursor) {
                        after = nextMerchantID
                        self.refreshMerchants(batchSize: batchSize, merchantIDs: merchantIDs, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion?(.success(PaginationInfo(response.paging?.cursors?.before, response.paging?.cursors?.after, response.paging?.total)))
                        }
                    }
            }
        }
        
    }
    
    /**
     Refresh merchant data for all cached merchants from the host
     
      - parameters:
        - count: Total number of cached merchants (if already known)
        - offset: Offset to fetch from (if already known)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshCachedMerchants(count: Int? = nil, offset: Int = 0, completion: FrolloSDKCompletionHandler? = nil) {
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let merchantCount: Int
            if let cachedCount = count {
                merchantCount = cachedCount
            } else {
                let countFetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                
                let fetchedCount = try? managedObjectContext.count(for: countFetchRequest)
                merchantCount = fetchedCount ?? 0
            }
            
            // Check we have some merchants to actually refresh
            guard merchantCount > 0
            else {
                completion?(.success)
                return
            }
            
            // Fetch all cached merchant IDs
            let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]
            fetchRequest.fetchBatchSize = merchantBatchSize
            fetchRequest.fetchOffset = offset
            fetchRequest.propertiesToFetch = [#keyPath(Merchant.merchantID)]
            
            do {
                let fetchedMerchantIDs = try managedObjectContext.fetch(fetchRequest)
                let cachedMerchantIDs = fetchedMerchantIDs.compactMap { $0.merchantID }
                
                service.fetchMerchants(merchantIDs: cachedMerchantIDs, size: merchantBatchSize) { result in
                    switch result {
                        
                        case .failure(let error):
                            Log.error(error.localizedDescription)
                            
                            DispatchQueue.main.async {
                                completion?(.failure(error))
                            }
                        case .success(let response):
                            let managedObjectContext = self.database.newBackgroundContext()
                            
                            self.handleMerchantsResponse(response.data.elements, merchantIDs: cachedMerchantIDs, managedObjectContext: managedObjectContext)
                            
                            self.linkTransactionsToMerchants(managedObjectContext: managedObjectContext)
                            
                            NotificationCenter.default.post(name: Aggregation.merchantsUpdatedNotification, object: self)
                            
                            let nextOffset = offset + self.merchantBatchSize
                            
                            if nextOffset >= merchantCount {
                                completion?(.success)
                            } else {
                                self.refreshCachedMerchants(count: merchantCount, offset: nextOffset, completion: completion)
                            }
                    }
                }
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    /**
     Search Merchants by keyword
     
     - parameters:
        - keyword: Search term
        - before: MerchantID for previous page (in string); Optional
        - after: MerchantID for next page (in string); Optional
        - size: Size of the page; Optional
        - completion: Optional completion handler with optional error if the request fails
     */
    public func searchMerchants(keyword: String, before: String? = nil, after: String? = nil, size: Int? = nil, completion: @escaping (Result<MerchantSearchResponse, Error>) -> Void) {
        
        service.fetchMerchants(keyword: keyword, before: before, after: after, size: size) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    var searchedMerchants = [MerchantSearchResult]()
                    response.data.elements.forEach { apiMerchant in
                        searchedMerchants.append(MerchantSearchResult(merchantID: apiMerchant.id, merchantName: apiMerchant.name, iconURL: apiMerchant.smallLogoURL))
                    }
                    
                    completion(.success(MerchantSearchResponse(searchedMerchants, response.paging?.cursors?.before, response.paging?.cursors?.after)))
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
    
    private func handleProviderAccountsResponse(_ providerAccountsResponse: [APIProviderAccountResponse], providerAccountIDs: [Int64], managedObjectContext: NSManagedObjectContext) {
        let predicate = NSPredicate(format: #keyPath(ProviderAccount.providerAccountID) + " IN %@", argumentArray: [providerAccountIDs])
        
        handleProviderAccountsResponse(providerAccountsResponse, predicate: predicate, managedObjectContext: managedObjectContext)
    }
    
    private func handleProviderAccountsResponse(_ providerAccountsResponse: [APIProviderAccountResponse], predicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) {
        providerAccountLock.lock()
        
        defer {
            providerAccountLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: ProviderAccount.self, objectsResponse: providerAccountsResponse, primaryKey: #keyPath(ProviderAccount.providerAccountID), linkedKeys: [\ProviderAccount.providerID], filterPredicate: predicate, managedObjectContext: managedObjectContext)
        
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
        linkingMerchantIDs.insert(transactionResponse.merchant.id)
        linkingTransactionCategoryIDs.insert(transactionResponse.categoryID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleTransactionsUserTags(_ response: [APITransactionTagResponse], managedObjectContext: NSManagedObjectContext) {
        userTagsLock.lock()
        defer {
            userTagsLock.unlock()
        }
        
        // Sort by ID
        let sortedTagResponses = response.sorted { (responseA, responseB) -> Bool in
            responseA.name.compare(responseB.name) == .orderedAscending
        }
        
        // Build name list predicate
        let tagNamesInResponse = response.map { $0.name }
        
        managedObjectContext.performAndWait {
            // Fetch existing objects for updating
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest() as! NSFetchRequest<Tag>
            fetchRequest.predicate = NSPredicate(format: #keyPath(Tag.name) + " IN %@", argumentArray: [tagNamesInResponse])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
            
            do {
                let existingTags = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for tagResponse in sortedTagResponses {
                    var tag: Tag
                    
                    if index < existingTags.count, existingTags[index].name == tagResponse.name {
                        tag = existingTags[index]
                        index += 1
                    } else {
                        tag = Tag(context: managedObjectContext)
                    }
                    
                    tag.update(response: tagResponse, context: managedObjectContext)
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<Tag> = Tag.fetchRequest() as! NSFetchRequest<Tag>
                deleteRequest.predicate = NSPredicate(format: "NOT " + #keyPath(Tag.name) + " IN %@", argumentArray: [tagNamesInResponse])
                
                do {
                    let deleteObjects = try managedObjectContext.fetch(deleteRequest)
                    
                    for deleteObject in deleteObjects {
                        managedObjectContext.delete(deleteObject)
                    }
                } catch let fetchError {
                    Log.error(fetchError.localizedDescription)
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
    
    private func handleUpdateTagsResponse(_ requestArray: [APITagUpdateRequest], isAdd: Bool = true, transactionID: Int64, managedObjectContext: NSManagedObjectContext) {
        transactionLock.lock()
        defer {
            transactionLock.unlock()
        }
        
        managedObjectContext.performAndWait {
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [transactionID])
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                if existingObjects.count > 0 {
                    
                    let currentTransaction = existingObjects[0]
                    let existingTags = currentTransaction.userTags
                    var updatedTags = existingTags
                    
                    if isAdd {
                        
                        for element in requestArray {
                            
                            if !existingTags.contains(element.name) {
                                updatedTags.append(element.name)
                            }
                            
                        }
                        
                    } else {
                        let currentTransaction = existingObjects[0]
                        let existingTags = currentTransaction.userTags
                        
                        let removedTags = requestArray.map { $0.name }
                        updatedTags = existingTags.filter { !removedTags.contains($0) }
                        
                    }
                    
                    currentTransaction.userTags = updatedTags
                }
                
            } catch let fetchError {
                Log.error(fetchError.localizedDescription)
            }
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
    }
    
    private func handleTransactionsResponse(transactionsResponse: APIPaginatedResponse<APITransactionResponse>, transactionFilter: TransactionFilter?, managedObjectContext: NSManagedObjectContext) {
        
        var filterPredicates = [NSPredicate]()
        
        var beforeDate: Date?
        var afterDate: Date?
        var beforeID: Int64?
        var afterID: Int64?
        
        // Upper limit predicate if not first page
        if let firstTransaction = transactionsResponse.data.elements.first, transactionsResponse.paging?.cursors?.before != nil {
            beforeID = firstTransaction.id
            beforeDate = Transaction.transactionDateFormatter.date(from: firstTransaction.transactionDate)
        }
        
        // Lower limit predicate if not last page
        if let lastTransaction = transactionsResponse.data.elements.last, transactionsResponse.paging?.cursors?.after != nil {
            afterID = lastTransaction.id
            afterDate = Transaction.transactionDateFormatter.date(from: lastTransaction.transactionDate)
        }
        
        // Filter by before cursor in paginated response
        if let beforeDate = beforeDate, let beforeID = beforeID, let dayAfterFirstDate = beforeDate.withAddingValue(1, to: .day) {
            
            let fromDateString = Transaction.transactionDateFormatter.string(from: beforeDate)
            let dayAfterFirstDateString = Transaction.transactionDateFormatter.string(from: dayAfterFirstDate)
            
            let filterPredicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " <= %@ ", argumentArray: [dayAfterFirstDateString])
            
            let firstDayFilterPredicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " == %@ && " + #keyPath(Transaction.transactionID) + " <= %@ ", argumentArray: [fromDateString, beforeID])
            
            filterPredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [filterPredicate, firstDayFilterPredicate]))
        }
        
        // Filter by after cursor in paginated response
        if let afterDate = afterDate, let afterID = afterID, let dayBeforeLastDate = afterDate.withAddingValue(-1, to: .day) {
            
            let toDateString = Transaction.transactionDateFormatter.string(from: afterDate)
            let dayBeforeLastDateString = Transaction.transactionDateFormatter.string(from: dayBeforeLastDate)
            
            let filterPredicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " >= %@ ", argumentArray: [dayBeforeLastDateString])
            
            let lastDayFilterPredicate = NSPredicate(format: #keyPath(Transaction.transactionDateString) + " == %@ && " + #keyPath(Transaction.transactionID) + " >= %@ ", argumentArray: [toDateString, afterID])
            
            filterPredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [filterPredicate, lastDayFilterPredicate]))
        }
        
        if let transactionFilterPredicates = transactionFilter?.filterPredicates {
            filterPredicates.append(contentsOf: transactionFilterPredicates)
        }
        
        transactionLock.lock()
        
        defer {
            transactionLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: Transaction.self, objectsResponse: transactionsResponse.data.elements, primaryKey: #keyPath(Transaction.transactionID), linkedKeys: [\Transaction.accountID, \Transaction.merchantID, \Transaction.transactionCategoryID], filterPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates), managedObjectContext: managedObjectContext)
        
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
    
    private func handleMerchantsResponse(_ merchantsResponse: [APIMerchantResponse], before: String?, after: String?, managedObjectContext: NSManagedObjectContext) {
        
        var predicates = [NSPredicate]()
        
        if let beforeID = Int64(before ?? "") {
            predicates.append(NSPredicate(format: #keyPath(Merchant.merchantID) + " > %ld", argumentArray: [beforeID]))
        }
        
        if let afterID = Int64(after ?? "") {
            predicates.append(NSPredicate(format: #keyPath(Merchant.merchantID) + " <= %ld", argumentArray: [afterID]))
        }
        
        handleMerchantsResponse(merchantsResponse, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), managedObjectContext: managedObjectContext)
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
        providerAccountLock.lock()
        
        defer {
            providerAccountLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: ProviderAccount.self, id: providerAccountID, primaryKey: #keyPath(ProviderAccount.providerAccountID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
}
