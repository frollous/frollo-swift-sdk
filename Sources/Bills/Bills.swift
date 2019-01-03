//
//  Bills.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/12/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

public class Bills: CachedObjects, ResponseHandler  {
    
    private let aggregation: Aggregation
    private let database: Database
    private let network: Network
    
    private let billsLock = NSLock()
    
    private var linkingAccountIDs = Set<Int64>()
    private var linkingMerchantIDs = Set<Int64>()
    private var linkingTransactionCategoryIDs = Set<Int64>()
    
    internal init(database: Database, network: Network, aggregation: Aggregation) {
        self.database = database
        self.network = network
        self.aggregation = aggregation
    }
    
    // MARK: - Bills
    
    /**
     Fetch bill by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - billID: Unique bill ID to fetch
     */
    public func bill(context: NSManagedObjectContext, billID: Int64) -> Bill? {
        return cachedObject(type: Bill.self, context: context, objectID: billID, objectKey: #keyPath(Bill.billID))
    }
    
    /**
     Fetch bills from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Bill` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to billID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func bills(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Bill.billID), ascending: true)], limit: Int? = nil) -> [Bill]? {
        return cachedObjects(type: Bill.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Bills from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Bill` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to billID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func billsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Bill.billID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Bill>? {
        return fetchedResultsController(type: Bill.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available bills from the host.
     
     Includes both estimated and confirmed bills.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBills(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchBills { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let billsResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillsResponse(billsResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Refresh a specific bill by ID from the host
     
     - parameters:
        - billID: ID of the bill to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBill(billID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchBill(billID: billID) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let billResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillResponse(billResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    /**
     Update a bill on the host
     
     - parameters:
        - billID: ID of the bill to be updated
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateBill(billID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard let bill = bill(context: database.newBackgroundContext(), billID: billID)
            else {
                let error = DataError(type: .database, subType: .notFound)
                
                DispatchQueue.main.async {
                    completion?(error)
                }
                return
        }
        
        let request = bill.updateRequest()
        
        network.updateBill(billID: billID, request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let billResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillResponse(billResponse, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkBillsToAccounts(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        
        defer {
            billsLock.unlock()
        }
        
        aggregation.linkObjectsToAccounts(type: Bill.self, managedObjectContext: managedObjectContext, linkingIDs: linkingAccountIDs, linkedKey: \Bill.accountID, linkedKeyName: #keyPath(Bill.accountID))
    }
    
    private func linkBillsToMerchants(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        
        defer {
            billsLock.unlock()
        }
        
        aggregation.linkObjectsToMerchants(type: Bill.self, managedObjectContext: managedObjectContext, linkingIDs: linkingMerchantIDs, linkedKey: \Bill.merchantID, linkedKeyName: #keyPath(Bill.merchantID))
    }
    
    private func linkBillsToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        
        defer {
            billsLock.unlock()
        }
        
        aggregation.linkObjectsToTransactionCategories(type: Bill.self, managedObjectContext: managedObjectContext, linkingIDs: linkingTransactionCategoryIDs, linkedKey: \Bill.transactionCategoryID, linkedKeyName: #keyPath(Bill.transactionCategoryID))
    }
    
    // MARK: - Response Handling
    
    private func handleBillsResponse(_ billsResponse: [APIBillResponse], managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        
        defer {
            billsLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: Bill.self, objectsResponse: billsResponse, primaryKey: #keyPath(Bill.billID), linkedKeys: [\Bill.accountID, \Bill.merchantID, \Bill.transactionCategoryID], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        if let accountIDs = updatedLinkedIDs[\Bill.accountID] {
            linkingAccountIDs = linkingAccountIDs.union(accountIDs)
        }
        if let merchantIDs = updatedLinkedIDs[\Bill.merchantID] {
            linkingMerchantIDs = linkingMerchantIDs.union(merchantIDs)
        }
        if let transactionCategoryIDs = updatedLinkedIDs[\Bill.transactionCategoryID] {
            linkingTransactionCategoryIDs = linkingTransactionCategoryIDs.union(transactionCategoryIDs)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleBillResponse(_ billResponse: APIBillResponse, managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        
        defer {
            billsLock.unlock()
        }
        
        updateObjectWithResponse(type: Bill.self, objectResponse: billResponse, primaryKey: #keyPath(Bill.billID), managedObjectContext: managedObjectContext)
        
        if let accountID = billResponse.accountID {
            linkingAccountIDs.insert(accountID)
        }
        if let merchantID = billResponse.merchant?.id {
            linkingMerchantIDs.insert(merchantID)
        }
        if let transactionCategoryID = billResponse.category?.id {
            linkingTransactionCategoryIDs.insert(transactionCategoryID)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
