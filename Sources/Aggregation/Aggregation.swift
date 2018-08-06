//
//  Aggregation.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

class Aggregation: ResponseHandler {
    
    private let database: Database
    private let network: Network
    
    private let accountLock = NSLock()
    private let providerLock = NSLock()
    private let providerAccountLock = NSLock()
    
    private var linkingProviderIDs = Set<Int64>()
    private var linkingProviderAccountIDs = Set<Int64>()
    
    internal init(database: Database, network: Network) {
        self.database = database
        self.network = network
    }
    
    // MARK: - Cache
    
    // MARK: - Updating Data
    
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
            
            completion?(error)
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
                    
                    self.linkProviderAccountsToProviders(managedObjectContext: managedObjectContext)
                }
            }
            
            completion?(error)
        }
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
            
            completion?(error)
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
            
            completion?(error)
        }
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
            
            completion?(error)
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
            
            completion?(error)
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
        
        let missingProviderIDs = linkObjectToParentObject(type: ProviderAccount.self, parentType: Provider.self, managedObjectContext: managedObjectContext, linkedIDs: linkingProviderIDs, linkedKey: "providerID")
        
        linkingProviderIDs = linkingProviderIDs.intersection(missingProviderIDs)
        
        for providerID in missingProviderIDs {
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
        
        linkObjectToParentObject(type: Account.self, parentType: ProviderAccount.self, managedObjectContext: managedObjectContext, linkedIDs: linkingProviderAccountIDs, linkedKey: "providerAccountID")
        
        linkingProviderAccountIDs = Set()
        
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
        
        updateObjectWithResponse(type: Provider.self, objectResponse: providerResponse, primaryKey: "providerID", managedObjectContext: managedObjectContext)
        
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
        
        let filterPredicate = NSPredicate(format: "statusRawValue IN %@", argumentArray: [[Provider.Status.supported.rawValue, Provider.Status.beta.rawValue]])
        
        updateObjectsWithResponse(type: Provider.self, objectsResponse: providersResponse, primaryKey: "providerID", filterPredicate: filterPredicate, managedObjectContext: managedObjectContext)
        
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
        
        updateObjectWithResponse(type: ProviderAccount.self, objectResponse: providerAccountResponse, primaryKey: "providerAccountID", managedObjectContext: managedObjectContext)
        
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
        
        let updatedProviderIDs = updateObjectsWithResponse(type: ProviderAccount.self, objectsResponse: providerAccountsResponse, primaryKey: "providerAccountID", filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        linkingProviderIDs = linkingProviderIDs.union(updatedProviderIDs)
        
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
        
        updateObjectWithResponse(type: Account.self, objectResponse: accountResponse, primaryKey: "accountID", managedObjectContext: managedObjectContext)
        
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
        
        let updatedProviderAccountIDs = updateObjectsWithResponse(type: Account.self, objectsResponse: accountsResponse, primaryKey: "accountID", filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        linkingProviderAccountIDs = linkingProviderAccountIDs.union(updatedProviderAccountIDs)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
