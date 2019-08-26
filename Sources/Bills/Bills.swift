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

/// Manages bills and bill payments
public class Bills: CachedObjects, ResponseHandler {
    
    private let aggregation: Aggregation
    private let authentication: Authentication
    private let database: Database
    private let service: APIService
    
    private let billsLock = NSLock()
    private let billPaymentsLock = NSLock()
    
    private var linkingAccountIDs = Set<Int64>()
    private var linkingBillIDs = Set<Int64>()
    private var linkingMerchantIDs = Set<Int64>()
    private var linkingTransactionCategoryIDs = Set<Int64>()
    private var refreshingMerchantIDs = Set<Int64>()
    
    internal init(database: Database, service: APIService, aggregation: Aggregation, authentication: Authentication) {
        self.database = database
        self.service = service
        self.aggregation = aggregation
        self.authentication = authentication
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
         - frequency: Filter by frequency of the bill payments (optional)
         - paymentStatus: Filter by the payment status (optional)
         - status: Filter by the status of the bill (optional)
         - type: Filter by the type of the bill (optional)
         - filteredBy: Predicate of properties to match for fetching. See `Bill` for properties (Optional)
         - sortedBy: Array of sort descriptors to sort the results by. Defaults to billID ascending (Optional)
         - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func bills(context: NSManagedObjectContext,
                      frequency: Bill.Frequency? = nil,
                      paymentStatus: Bill.PaymentStatus? = nil,
                      status: Bill.Status? = nil,
                      type: Bill.BillType? = nil,
                      filteredBy predicate: NSPredicate? = nil,
                      sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Bill.billID), ascending: true)],
                      limit: Int? = nil) -> [Bill]? {
        var predicates = [NSPredicate]()
        
        if let filterFrequency = frequency {
            predicates.append(NSPredicate(format: #keyPath(Bill.frequencyRawValue) + " == %@", argumentArray: [filterFrequency.rawValue]))
        }
        if let filterPaymentStatus = paymentStatus {
            predicates.append(NSPredicate(format: #keyPath(Bill.paymentStatusRawValue) + " == %@", argumentArray: [filterPaymentStatus.rawValue]))
        }
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Bill.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(Bill.billTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Bill.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Bills from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - frequency: Filter by frequency of the bill payments (optional)
        - paymentStatus: Filter by the payment status (optional)
        - status: Filter by the status of the bill (optional)
        - type: Filter by the type of the bill (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Bill` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to billID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func billsFetchedResultsController(context: NSManagedObjectContext,
                                              frequency: Bill.Frequency? = nil,
                                              paymentStatus: Bill.PaymentStatus? = nil,
                                              status: Bill.Status? = nil,
                                              type: Bill.BillType? = nil,
                                              filteredBy predicate: NSPredicate? = nil,
                                              sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Bill.billID), ascending: true)],
                                              limit: Int? = nil) -> NSFetchedResultsController<Bill>? {
        var predicates = [NSPredicate]()
        
        if let filterFrequency = frequency {
            predicates.append(NSPredicate(format: #keyPath(Bill.frequencyRawValue) + " == %@", argumentArray: [filterFrequency.rawValue]))
        }
        if let filterPaymentStatus = paymentStatus {
            predicates.append(NSPredicate(format: #keyPath(Bill.paymentStatusRawValue) + " == %@", argumentArray: [filterPaymentStatus.rawValue]))
        }
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Bill.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(Bill.billTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Bill.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Create a new bill on the host from a transaction
     
     - parameters:
        - transactionID: ID of the transaction representing a bill payment
        - frequency: How often the bill recurrs
        - nextPaymentDate: Date of the next payment is due
        - name: Custom name for the bill (Optional: defaults to the transaction name)
        - notes: Notes attached to the bill (Optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func createBill(transactionID: Int64, frequency: Bill.Frequency, nextPaymentDate: Date, name: String? = nil, notes: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        let date = Bill.billDateFormatter.string(from: nextPaymentDate)
        
        let request = APIBillCreateRequest(accountID: nil,
                                           dueAmount: nil,
                                           frequency: frequency,
                                           name: name,
                                           nextPaymentDate: date,
                                           notes: notes,
                                           transactionID: transactionID)
        
        createBill(request: request, completion: completion)
    }
    
    /**
     Create a new bill on the host manually
     
     - parameters:
         - accountID: ID of the account the bill is paid from
         - dueAmount: Amount the bill charges, recurring
         - frequency: How often the bill recurrs
         - nextPaymentDate: Date of the next payment is due
         - name: Custom name for the bill (Optional: defaults to the transaction name)
         - notes: Notes attached to the bill (Optional)
         - completion: Optional completion handler with optional error if the request fails
     */
    public func createBill(accountID: Int64, dueAmount: Decimal, frequency: Bill.Frequency, nextPaymentDate: Date, name: String, notes: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        let date = Bill.billDateFormatter.string(from: nextPaymentDate)
        
        let amount = dueAmount as NSDecimalNumber
        
        let request = APIBillCreateRequest(accountID: accountID,
                                           dueAmount: amount.stringValue,
                                           frequency: frequency,
                                           name: name,
                                           nextPaymentDate: date,
                                           notes: notes,
                                           transactionID: nil)
        
        createBill(request: request, completion: completion)
    }
    
    private func createBill(request: APIBillCreateRequest, completion: FrolloSDKCompletionHandler? = nil) {
        service.createBill(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Delete a specific bill by ID from the host
     
     - parameters:
        - billID: ID of the bill to be deleted
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteBill(billID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.deleteBill(billID: billID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedBill(billID: billID)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh all available bills from the host.
     
     Includes both estimated and confirmed bills.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBills(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchBills { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillsResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        service.fetchBill(billID: billID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
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
        let managedObjectContext = database.newBackgroundContext()
        
        guard let bill = bill(context: managedObjectContext, billID: billID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APIBillUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = bill.updateRequest()
        }
        
        service.updateBill(billID: billID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBillsToAccounts(managedObjectContext: managedObjectContext)
                    self.linkBillsToMerchants(managedObjectContext: managedObjectContext)
                    self.linkBillsToTransactionCategories(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Bill Payments
    
    /**
     Fetch bill payment by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - billPaymentID: Unique bill payment ID to fetch
     */
    public func billPayment(context: NSManagedObjectContext, billPaymentID: Int64) -> BillPayment? {
        return cachedObject(type: BillPayment.self, context: context, objectID: billPaymentID, objectKey: #keyPath(BillPayment.billPaymentID))
    }
    
    /**
     Fetch bill payments from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - frequency: Filter by frequency of the bill payments (optional)
        - status: Filter by the payment status (optional)
        - filteredBy: Predicate of properties to match for fetching. See `BillPayment` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to billPaymentID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func billPayments(context: NSManagedObjectContext,
                             frequency: Bill.Frequency? = nil,
                             status: Bill.PaymentStatus? = nil,
                             filteredBy predicate: NSPredicate? = nil,
                             sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(BillPayment.billPaymentID), ascending: true)],
                             limit: Int? = nil) -> [BillPayment]? {
        var predicates = [NSPredicate]()
        
        if let filterFrequency = frequency {
            predicates.append(NSPredicate(format: #keyPath(Bill.frequencyRawValue) + " == %@", argumentArray: [filterFrequency.rawValue]))
        }
        if let filterPaymentStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Bill.paymentStatusRawValue) + " == %@", argumentArray: [filterPaymentStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: BillPayment.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Bill Payments from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - frequency: Filter by frequency of the bill payments (optional)
        - status: Filter by the payment status (optional)
        - filteredBy: Predicate of properties to match for fetching. See `BillPayment` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to billPaymentID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func billPaymentsFetchedResultsController(context: NSManagedObjectContext,
                                                     frequency: Bill.Frequency? = nil,
                                                     status: Bill.PaymentStatus? = nil,
                                                     filteredBy predicate: NSPredicate? = nil,
                                                     sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(BillPayment.billPaymentID), ascending: true)],
                                                     limit: Int? = nil) -> NSFetchedResultsController<BillPayment>? {
        var predicates = [NSPredicate]()
        
        if let filterFrequency = frequency {
            predicates.append(NSPredicate(format: #keyPath(Bill.frequencyRawValue) + " == %@", argumentArray: [filterFrequency.rawValue]))
        }
        if let filterPaymentStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Bill.paymentStatusRawValue) + " == %@", argumentArray: [filterPaymentStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: BillPayment.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Delete a specific bill payment by ID from the host
     
     - parameters:
        - billPaymentID: ID of the bill payment to be deleted
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteBillPayment(billPaymentID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.deleteBillPayment(billPaymentID: billPaymentID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedBillPayment(billPaymentID: billPaymentID)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh bill payments from a certain period from the host
     
     - parameters:
        - fromDate: Start date to fetch bill payments from (inclusive)
        - toDate: End date to fetch bill payments up to (inclusive)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBillPayments(from fromDate: Date, to toDate: Date, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchBillPayments(from: fromDate, to: toDate) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillPaymentsResponse(response, from: fromDate, to: toDate, managedObjectContext: managedObjectContext)
                    
                    self.linkBillPaymentsToBills(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific bill payment by ID from the host
     
     - parameters:
        - billPaymentID: ID of the bill payment to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBillPayment(billPaymentID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchBillPayment(billPaymentID: billPaymentID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillPaymentResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBillPaymentsToBills(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a bill payment on the host
     
     - parameters:
     - billPaymentID: ID of the bill payment to be updated
     - completion: Optional completion handler with optional error if the request fails
     */
    public func updateBillPayment(billPaymentID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        let managedObjectContext = database.newBackgroundContext()
        
        guard let billPayment = billPayment(context: managedObjectContext, billPaymentID: billPaymentID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APIBillPaymentUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = billPayment.updateRequest()
        }
        
        service.updateBillPayment(billPaymentID: billPaymentID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBillPaymentResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBillPaymentsToBills(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkBillsToAccounts(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        aggregation.accountLock.lock()
        
        defer {
            billsLock.unlock()
            aggregation.accountLock.unlock()
        }
        
        linkObjectToParentObject(type: Bill.self, parentType: Account.self, managedObjectContext: managedObjectContext, linkedIDs: linkingAccountIDs, linkedKey: \Bill.accountID, linkedKeyName: #keyPath(Bill.accountID))
        
        linkingAccountIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkBillsToMerchants(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        aggregation.merchantLock.lock()
        
        defer {
            billsLock.unlock()
            aggregation.merchantLock.unlock()
        }
        
        let missingMerchantIDs = linkObjectToParentObject(type: Bill.self, parentType: Merchant.self, managedObjectContext: managedObjectContext, linkedIDs: linkingMerchantIDs, linkedKey: \Bill.merchantID, linkedKeyName: #keyPath(Bill.merchantID))
        
        linkingMerchantIDs = missingMerchantIDs
        
        let merchantIDs = missingMerchantIDs.subtracting(refreshingMerchantIDs)
        
        if !merchantIDs.isEmpty {
            refreshingMerchantIDs = refreshingMerchantIDs.union(merchantIDs)
            aggregation.refreshMerchants(merchantIDs: Array(merchantIDs))
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkBillsToTransactionCategories(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        aggregation.transactionCategoryLock.lock()
        
        defer {
            billsLock.unlock()
            aggregation.transactionCategoryLock.unlock()
        }
        
        linkObjectToParentObject(type: Bill.self, parentType: TransactionCategory.self, managedObjectContext: managedObjectContext, linkedIDs: linkingTransactionCategoryIDs, linkedKey: \Bill.transactionCategoryID, linkedKeyName: #keyPath(Bill.transactionCategoryID))
        
        linkingTransactionCategoryIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func linkBillPaymentsToBills(managedObjectContext: NSManagedObjectContext) {
        billsLock.lock()
        billPaymentsLock.lock()
        
        defer {
            billsLock.unlock()
            billPaymentsLock.unlock()
        }
        
        linkObjectToParentObject(type: BillPayment.self, parentType: Bill.self, managedObjectContext: managedObjectContext, linkedIDs: linkingBillIDs, linkedKey: \BillPayment.billID, linkedKeyName: #keyPath(BillPayment.billID))
        
        linkingBillIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
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
    
    private func handleBillPaymentsResponse(_ billPaymentsResponse: [APIBillPaymentResponse], from fromDate: Date, to toDate: Date, managedObjectContext: NSManagedObjectContext) {
        let fromDateString = BillPayment.billDateFormatter.string(from: fromDate)
        let toDateString = BillPayment.billDateFormatter.string(from: toDate)
        
        let predicate = NSPredicate(format: #keyPath(BillPayment.dateString) + " >= %@ && " + #keyPath(BillPayment.dateString) + " <= %@", argumentArray: [fromDateString, toDateString])
        
        billPaymentsLock.lock()
        
        defer {
            billPaymentsLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: BillPayment.self, objectsResponse: billPaymentsResponse, primaryKey: #keyPath(BillPayment.billPaymentID), linkedKeys: [\BillPayment.billID], filterPredicate: predicate, managedObjectContext: managedObjectContext)
        
        if let billIDs = updatedLinkedIDs[\BillPayment.billID] {
            linkingBillIDs = linkingBillIDs.union(billIDs)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleBillPaymentResponse(_ billPaymentResponse: APIBillPaymentResponse, managedObjectContext: NSManagedObjectContext) {
        billPaymentsLock.lock()
        
        defer {
            billPaymentsLock.unlock()
        }
        
        updateObjectWithResponse(type: BillPayment.self, objectResponse: billPaymentResponse, primaryKey: #keyPath(BillPayment.billPaymentID), managedObjectContext: managedObjectContext)
        
        linkingBillIDs.insert(billPaymentResponse.billID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func removeCachedBill(billID: Int64) {
        billsLock.lock()
        
        defer {
            billsLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: Bill.self, id: billID, primaryKey: #keyPath(Bill.billID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func removeCachedBillPayment(billPaymentID: Int64) {
        billPaymentsLock.lock()
        
        defer {
            billPaymentsLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: BillPayment.self, id: billPaymentID, primaryKey: #keyPath(BillPayment.billPaymentID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
