//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreData
import Foundation
import SwiftyJSON

/// Manages user budgets and tracking
public class Budgets: CachedObjects, ResponseHandler {
    
    private let database: Database
    private let service: APIService
    
    private let budgetsLock = NSLock()
    private let budgetPeriodsLock = NSLock()
    
    private var linkingBudgetIDs = Set<Int64>()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    /// Notification fired when silent push notification recieved when current budget period is ready
    public static let currentBudgetPeriodReadyNotification = Notification.Name("FrolloSDK.budgets.currentBudgetPeriodReadyNotification")
    
    // MARK: - Budgets
    
    /**
     Fetch budget by ID from the cache
     
     - parameters:
         - context: Managed object context to fetch these from; background or main thread
         - budgetID: Unique budget ID to fetch
     */
    public func budget(context: NSManagedObjectContext, budgetID: Int64) -> Budget? {
        return cachedObject(type: Budget.self, context: context, objectID: budgetID, objectKey: #keyPath(Budget.budgetID))
    }
    
    /**
     Fetch budgets from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - current: Filter budgets by current budget (optional)
        - budgetType: Filter by type of the budget (optional)
        - typeValue: Filter by  type value of the budget (optional). budget category name, category ID or merchant ID
        - frequency: Filter by frequency of the budget (optional)
        - status: Filter by status of the budget (optional)
        - trackingStatus: Filter by tracking status of the budget (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Budget` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to budgetID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func budgets(context: NSManagedObjectContext,
                        current: Bool? = nil,
                        budgetType: Budget.BudgetType? = nil,
                        typeValue: String? = nil,
                        frequency: Budget.Frequency? = nil,
                        status: Budget.Status? = nil,
                        trackingStatus: Budget.TrackingStatus? = nil,
                        filteredBy predicate: NSPredicate? = nil,
                        sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Budget.budgetID), ascending: true)],
                        limit: Int? = nil) -> [Budget]? {
        
        var predicates = [NSPredicate]()
        
        if let isCurrentBudget = current {
            predicates.append(NSPredicate(format: #keyPath(Budget.isCurrent) + " == %ld", argumentArray: [isCurrentBudget]))
        }
        
        if let filterBudgetType = budgetType {
            predicates.append(NSPredicate(format: #keyPath(Budget.typeRawValue) + " == %@", argumentArray: [filterBudgetType.rawValue]))
        }
        
        if let filterTypeValue = typeValue {
            predicates.append(NSPredicate(format: #keyPath(Budget.typeValue) + " == %@", argumentArray: [filterTypeValue]))
        }
        
        if let filterFrequency = frequency {
            predicates.append(NSPredicate(format: #keyPath(Budget.frequencyRawValue) + " == %@", argumentArray: [filterFrequency.rawValue]))
        }
        
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Budget.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        
        if let filterTrackingStatus = trackingStatus {
            predicates.append(NSPredicate(format: #keyPath(Budget.trackingStatusRawValue) + " == %@", argumentArray: [filterTrackingStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Budget.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Budgets from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - current: Filter budgets by current budget (optional)
        - budgetType: Filter by type of the budget (optional)
        - typeValue: Filter by  type value of the budget (optional). budget category name, category ID or merchant ID
        - frequency: Filter by frequency of the budget (optional)
        - status: Filter by status of the budget (optional)
        - trackingStatus: Filter by tracking status of the budget (optional)
        - trackingType: Filter by tracking type of the budget (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Budget` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to budgetID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func budgetsFetchedResultsController(context: NSManagedObjectContext,
                                                current: Bool? = nil,
                                                budgetType: Budget.BudgetType? = nil,
                                                typeValue: String? = nil,
                                                frequency: Budget.Frequency? = nil,
                                                status: Budget.Status? = nil,
                                                trackingStatus: Budget.TrackingStatus? = nil,
                                                trackingType: Budget.TrackingType,
                                                filteredBy predicate: NSPredicate? = nil,
                                                sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Budget.budgetID), ascending: true)],
                                                limit: Int? = nil) -> NSFetchedResultsController<Budget>? {
        
        var predicates = [NSPredicate]()
        
        if let isCurrentBudget = current {
            predicates.append(NSPredicate(format: #keyPath(Budget.isCurrent) + " == %ld", argumentArray: [isCurrentBudget]))
        }
        
        if let filterBudgetType = budgetType {
            predicates.append(NSPredicate(format: #keyPath(Budget.typeRawValue) + " == %@", argumentArray: [filterBudgetType.rawValue]))
        }
        
        if let filterTypeValue = typeValue {
            predicates.append(NSPredicate(format: #keyPath(Budget.typeValue) + " == %@", argumentArray: [filterTypeValue]))
        }
        
        if let filterFrequency = frequency {
            predicates.append(NSPredicate(format: #keyPath(Budget.frequencyRawValue) + " == %@", argumentArray: [filterFrequency.rawValue]))
        }
        
        if let filterStatus = status {
            predicates.append(NSPredicate(format: #keyPath(Budget.statusRawValue) + " == %@", argumentArray: [filterStatus.rawValue]))
        }
        
        if let filterTrackingStatus = trackingStatus {
            predicates.append(NSPredicate(format: #keyPath(Budget.trackingStatusRawValue) + " == %@", argumentArray: [filterTrackingStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Budget.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh a specific budget by ID from the host
     
     - parameters:
         - budgetID: ID of the budget to fetch
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBudget(budgetID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchBudget(budgetID: budgetID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh all available budgets from the host.
     
     - parameters:
        - current: Filter by current budget (Optional)
        - budgetType: Filter budget by budget `BudgetType`, defaults to budgetCategory (Optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBudgets(current: Bool? = nil, budgetType: Budget.BudgetType? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchBudgets(current: current, budgetType: budgetType) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetsResponse(response, current: current, budgetType: budgetType, managedObjectContext: managedObjectContext)
                    
                    // Handle Current Period of budgets
                    let currentPeriods = response.compactMap { $0.currentPeriod }
                    for currentPeriod in currentPeriods {
                        
                        self.handleBudgetPeriodResponse(currentPeriod, managedObjectContext: managedObjectContext)
                    }
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Create a new budget by account on the host
     
     - parameters:
         - accountID: accountID of an `Account` to create a budget
         - frequency: Frequency of  the budget
         - periodAmount: Budget amount for one budget period
         - imageURL: Image Url of the budget (Optional)
         - startDate: start date of the budget (Optional)
         - metadata: Optional JSON metadata accociated withf the budget
         - completion: Optional completion handler with optional error if the request fails
     */
    public func createAccountBudget(accountID: Int64,
                                    frequency: Budget.Frequency,
                                    periodAmount: Decimal,
                                    imageURL: String? = nil,
                                    startDate: String? = nil,
                                    metadata: JSON = [:],
                                    completion: FrolloSDKCompletionHandler? = nil) {
        
        createBudget(frequency: frequency, periodAmount: periodAmount, budgetType: .account, typeValue: "\(accountID)", imageURL: imageURL, startDate: startDate, metadata: metadata, completion: completion)
        
    }
    
    /**
     Create a new budget by budget category on the host
     
     - parameters:
         - budgetCategory: `BudgetCategory` to create a budget
         - frequency: Frequency of  the budget
         - periodAmount: Budget amount for one budget period
         - imageURL: Image Url of the budget (Optional)
         - startDate: start date of the budget (Optional)
         - metadata: Optional JSON metadata accociated withf the budget
         - completion: Optional completion handler with optional error if the request fails
     */
    public func createBudgetCategoryBudget(budgetCategory: BudgetCategory,
                                           frequency: Budget.Frequency,
                                           periodAmount: Decimal,
                                           imageURL: String? = nil,
                                           startDate: String? = nil,
                                           metadata: JSON = [:],
                                           completion: FrolloSDKCompletionHandler? = nil) {
        
        createBudget(frequency: frequency, periodAmount: periodAmount, budgetType: .budgetCategory, typeValue: budgetCategory.rawValue, imageURL: imageURL, startDate: startDate, metadata: metadata, completion: completion)
        
    }
    
    /**
     Create a new budget by category on the host
     
     - parameters:
         - categoryID: id of the `Category` to create a budget
         - frequency: Frequency of  the budget
         - periodAmount: Budget amount for one budget period
         - imageURL: Image Url of the budget (Optional)
         - startDate: start date of the budget (Optional)
         - metadata: Optional JSON metadata accociated withf the budget
         - completion: Optional completion handler with optional error if the request fails
     */
    public func createCategoryBudget(categoryID: Int64,
                                     frequency: Budget.Frequency,
                                     periodAmount: Decimal,
                                     imageURL: String? = nil,
                                     startDate: String? = nil,
                                     metadata: JSON = [:],
                                     completion: FrolloSDKCompletionHandler? = nil) {
        
        createBudget(frequency: frequency, periodAmount: periodAmount, budgetType: .category, typeValue: "\(categoryID)", imageURL: imageURL, startDate: startDate, metadata: metadata, completion: completion)
        
    }
    
    /**
     Create a new budget by merchant on the host
     
     - parameters:
         - merchantID: id of the `Merchant` to create a budget
         - frequency: Frequency of  the budget
         - periodAmount: Budget amount for one budget period
         - imageURL: Image Url of the budget (Optional)
         - startDate: start date of the budget (Optional)
         - metadata: Optional JSON metadata accociated withf the budget
         - completion: Optional completion handler with optional error if the request fails
     */
    public func createMerchantBudget(merchantID: Int64,
                                     frequency: Budget.Frequency,
                                     periodAmount: Decimal,
                                     imageURL: String? = nil,
                                     startDate: String? = nil,
                                     metadata: JSON = [:],
                                     completion: FrolloSDKCompletionHandler? = nil) {
        
        createBudget(frequency: frequency, periodAmount: periodAmount, budgetType: .merchant, typeValue: "\(merchantID)", imageURL: imageURL, startDate: startDate, metadata: metadata, completion: completion)
        
    }
    
    private func createBudget(frequency: Budget.Frequency,
                              periodAmount: Decimal,
                              budgetType: Budget.BudgetType,
                              typeValue: String,
                              imageURL: String? = nil,
                              startDate: String? = nil,
                              metadata: JSON = [:],
                              completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APIBudgetCreateRequest(frequency: frequency, periodAmount: String(decimal: periodAmount), type: budgetType, typeValue: typeValue, imageURL: imageURL, startDate: startDate, metadata: metadata)
        
        guard request.valid()
        else {
            let error = DataError(type: .api, subType: .invalidData)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.createBudget(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Detele a specific budget by ID from the host
     
     - parameters:
        - budgetID: ID of the budget to be deleted
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteBudget(budgetID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.deleteBudget(budgetID: budgetID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedBudget(budgetID: budgetID)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a budget on the host
     
     - parameters:
        - budgetID: ID of the budget to be updated
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateBudget(budgetID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        let managedObjectContext = database.newBackgroundContext()
        
        guard let budget = budget(context: managedObjectContext, budgetID: budgetID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APIBudgetUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = budget.updateRequest()
        }
        
        service.updateBudget(budgetID: budgetID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Budget Periods
    
    /**
     Fetch budget period by ID from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - budgetPeriodID: Unique budget period ID to fetch
     */
    public func budgetPeriod(context: NSManagedObjectContext, budgetPeriodID: Int64) -> BudgetPeriod? {
        return cachedObject(type: BudgetPeriod.self, context: context, objectID: budgetPeriodID, objectKey: #keyPath(BudgetPeriod.budgetPeriodID))
    }
    
    /**
     Fetch budget periods from the cache
     
     - parameters:
         - context: Managed object context to fetch these from; background or main thread
         - budgetID: Filter by budgetID (Optional)
         - trackingStatus: Filter by tracking status of the period
         - filteredBy: Predicate of properties to match for fetching. See `Budget` for properties (Optional)
         - sortedBy: Array of sort descriptors to sort the results by. Defaults to budgetPeriodID ascending (Optional)
         - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func budgetPeriods(context: NSManagedObjectContext, budgetID: Int64? = nil,
                              trackingStatus: Budget.TrackingStatus? = nil,
                              filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(BudgetPeriod.budgetPeriodID), ascending: true)],
                              limit: Int? = nil) -> [BudgetPeriod]? {
        
        var predicates = [NSPredicate]()
        
        if let filterBudgetID = budgetID {
            predicates.append(NSPredicate(format: #keyPath(BudgetPeriod.budgetID) + " == %ld", argumentArray: [filterBudgetID]))
        }
        
        if let filterTrackingStatus = trackingStatus {
            predicates.append(NSPredicate(format: #keyPath(Budget.trackingStatusRawValue) + " == %@", argumentArray: [filterTrackingStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: BudgetPeriod.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of budget periods from the cache
     
     - parameters:
         - context: Managed object context to fetch these from; background or main thread
         - budgetID: Filter by budgetID (Optional)
         - trackingStatus: Filter by tracking status of the period (Optional)
         - filteredBy: Predicate of properties to match for fetching. See `BudgetPeriod` for properties (Optional)
         - sortedBy: Array of sort descriptors to sort the results by. Defaults to budgetPeriodID ascending (Optional)
         - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func budgetPeriodsFetchedResultsController(context: NSManagedObjectContext, budgetID: Int64? = nil, trackingStatus: Budget.TrackingStatus? = nil,
                                                      filteredBy predicate: NSPredicate? = nil,
                                                      sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(BudgetPeriod.budgetPeriodID), ascending: true)],
                                                      limit: Int? = nil) -> NSFetchedResultsController<BudgetPeriod>? {
        
        var predicates = [NSPredicate]()
        
        if let filterBudgetID = budgetID {
            predicates.append(NSPredicate(format: #keyPath(BudgetPeriod.budgetID) + " == %ld", argumentArray: [filterBudgetID]))
        }
        
        if let filterTrackingStatus = trackingStatus {
            predicates.append(NSPredicate(format: #keyPath(Budget.trackingStatusRawValue) + " == %@", argumentArray: [filterTrackingStatus.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: BudgetPeriod.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh a specific budget period by ID from the host
     
     - parameters:
         - budgetID: ID of the budget the period is associated with
         - budgetPeriodID: ID of the budget period to fetch
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBudgetPeriod(budgetID: Int64, budgetPeriodID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchBudgetPeriod(budgetID: budgetID, budgetPeriodID: budgetPeriodID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetPeriodResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh all budget periods from the host.
     
     - parameters:
        - before: before field to get previous list in pagination. Format is "<epoch_date>_<id>"(Optional)
        - after: after field to get next list in pagination. Format is "<epoch_date>_<id>"(Optional)
        - size: Batch size of budget periods to returned by API (optional); defaults to 500
        - fromDate: Start date to fetch budget periods from (Optional)
        - toDate: End date to fetch budget periods up to (Optional)
        - status: Filter by status of the budget (optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshAllBudgetPeriods(before: String? = nil, after: String? = nil, size: Int? = 500, from fromDate: Date? = nil, to toDate: Date? = nil, status: Budget.Status? = nil, completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        service.fetchBudgetPeriods(before: before, after: after, size: size, budgetID: nil, from: fromDate, to: toDate) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetPeriodsResponse(response.data.elements, before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, budgetID: nil, from: fromDate, to: toDate, status: status, managedObjectContext: managedObjectContext)
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfo(response.paging?.cursors?.before, response.paging?.cursors?.after, response.paging?.total)))
                    }
            }
        }
    }
    
    /**
     Refresh budget periods for a budget from the host.
     
     - parameters:
        - before: before field to get previous list in pagination. Format is "<epoch_date>_<id>"(Optional)
        - after: after field to get next list in pagination. Format is "<epoch_date>_<id>"(Optional)
        - size: Batch size of budget periods to returned by API (optional); defaults to 500
        - budgetID: ID of the budget to fetch periods for
        - fromDate: Start date to fetch budget periods from (Optional)
        - toDate: End date to fetch budget periods up to (Optional)
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshBudgetPeriods(before: String? = nil, after: String? = nil, size: Int? = 500, budgetID: Int64, from fromDate: Date? = nil, to toDate: Date? = nil, completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        service.fetchBudgetPeriods(before: before, after: after, size: size, budgetID: budgetID, from: fromDate, to: toDate) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleBudgetPeriodsResponse(response.data.elements, before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, budgetID: budgetID, from: fromDate, to: toDate, managedObjectContext: managedObjectContext)
                    
                    self.linkBudgetPeriodsToBudgets(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfo(response.paging?.cursors?.before, response.paging?.cursors?.after, response.paging?.total)))
                    }
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkBudgetPeriodsToBudgets(managedObjectContext: NSManagedObjectContext) {
        budgetsLock.lock()
        budgetPeriodsLock.lock()
        
        defer {
            budgetsLock.unlock()
            budgetPeriodsLock.unlock()
        }
        
        linkObjectToParentObject(type: BudgetPeriod.self, parentType: Budget.self, managedObjectContext: managedObjectContext, linkedIDs: linkingBudgetIDs, linkedKey: \BudgetPeriod.budgetID, linkedKeyName: #keyPath(BudgetPeriod.budgetID))
        
        linkingBudgetIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleBudgetResponse(_ budgetResponse: APIBudgetResponse, managedObjectContext: NSManagedObjectContext) {
        budgetsLock.lock()
        
        defer {
            budgetsLock.unlock()
        }
        
        updateObjectWithResponse(type: Budget.self, objectResponse: budgetResponse, primaryKey: #keyPath(Budget.budgetID), managedObjectContext: managedObjectContext)
        
        if let currentBudgetResponse = budgetResponse.currentPeriod {
            handleBudgetPeriodResponse(currentBudgetResponse, managedObjectContext: managedObjectContext)
            
            linkingBudgetIDs.insert(currentBudgetResponse.budgetID)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleBudgetsResponse(_ budgetsResponse: [APIBudgetResponse], current: Bool?, budgetType: Budget.BudgetType?, managedObjectContext: NSManagedObjectContext) {
        budgetsLock.lock()
        
        defer {
            budgetsLock.unlock()
        }
        
        var predicates = [NSPredicate]()
        if let current = current {
            predicates.append(NSPredicate(format: #keyPath(Budget.isCurrent) + " == %ld", argumentArray: [current]))
        }
        if let budgetType = budgetType {
            predicates.append(NSPredicate(format: #keyPath(Budget.typeRawValue) + " == %@", argumentArray: [budgetType.rawValue]))
        }
        
        var filterPredicate: NSPredicate?
        if !predicates.isEmpty {
            filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        updateObjectsWithResponse(type: Budget.self, objectsResponse: budgetsResponse, primaryKey: #keyPath(Budget.budgetID), linkedKeys: [], filterPredicate: filterPredicate, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
    }
    
    private func handleBudgetPeriodResponse(_ budgetPeriodResponse: APIBudgetPeriodResponse, managedObjectContext: NSManagedObjectContext) {
        budgetPeriodsLock.lock()
        
        defer {
            budgetPeriodsLock.unlock()
        }
        
        updateObjectWithResponse(type: BudgetPeriod.self, objectResponse: budgetPeriodResponse, primaryKey: #keyPath(BudgetPeriod.budgetPeriodID), managedObjectContext: managedObjectContext)
        
        linkingBudgetIDs.insert(budgetPeriodResponse.budgetID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleBudgetPeriodsResponse(_ budgetPeriodsResponse: [APIBudgetPeriodResponse], before: String?, after: String?, budgetID: Int64?, from fromDate: Date? = nil, to toDate: Date? = nil, status: Budget.Status? = nil, managedObjectContext: NSManagedObjectContext) {
        
        var predicates = [NSPredicate]()
        
        var beforeDate: Date?
        var afterDate: Date?
        var beforeID: Int64?
        var afterID: Int64?
        
        // Lower limit predicate if not first page
        if let id = budgetPeriodsResponse.first?.id, let afterDateString = budgetPeriodsResponse.first?.startDate, before != nil {
            
            afterID = id
            afterDate = BudgetPeriod.budgetPeriodDateFormatter.date(from: afterDateString)
        }
        
        // Upper limit predicate if not last page
        if let id = budgetPeriodsResponse.last?.id, let beforeDateString = budgetPeriodsResponse.last?.startDate, after != nil {
            
            beforeID = id
            beforeDate = BudgetPeriod.budgetPeriodDateFormatter.date(from: beforeDateString)
        }
        
        /**
         Following code creates a filter predicate that will be applied to cached transactions to update
         Predicate 1: Considers all budget periods after start date of first budget period (date of first budget period + 1)
         Predicate 2: Considers all budget periods as of the date of first budget period and higher than or equal to the ID of the first budget period
         Predicate 3: Considers all budget periods before the date of last budget period (date of last budget period - 1)
         Predicate 4: Considers all budget periods of the date of last budget period but lower than or equal to the ID of the last budget period
         Predicate 5: Predicate 1 OR Predicate 2 (Upper limit Predicate)
         Predicate 6: Predicate 2 OR Predicate 4 (Lower limit Predicate)
         Predicate 7: Predicate 5 AND Predicate 6 (Satisfy both upper and lower limit) (Final filter predicate to apply in core data)
         */
        
        // Filter by after cursor in paginated response
        if let afterDate = afterDate, let afterID = afterID, let dayAfterFirstDate = afterDate.withAddingValue(1, to: .day) {
            
            let toDateString = BudgetPeriod.budgetPeriodDateFormatter.string(from: afterDate)
            let dayAfterFirstDateString = BudgetPeriod.budgetPeriodDateFormatter.string(from: dayAfterFirstDate)
            
            // Filter for other days except first day. All budget periods can be considered after afterDate (one day after the date of first budget period). This means we dont need to consider budgetPeriodIDs here.
            let filterPredicate = NSPredicate(format: #keyPath(BudgetPeriod.startDateString) + " >= %@ ", argumentArray: [dayAfterFirstDateString])
            
            // Fiest day filter. For the first date in budget period list, the day should be equal to date of the first budget period and budgetPeriodID should be before last transaction ID (afterID).
            let lastDayFilterPredicate = NSPredicate(format: #keyPath(BudgetPeriod.startDateString) + " == %@ && " + #keyPath(BudgetPeriod.budgetPeriodID) + " >= %@ ", argumentArray: [toDateString, afterID])
            
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [filterPredicate, lastDayFilterPredicate]))
        }
        
        // Filter by before cursor in paginated response
        if let beforeDate = beforeDate, let beforeID = beforeID, let dayBeforeLastDate = beforeDate.withAddingValue(-1, to: .day) {
            
            let fromDateString = BudgetPeriod.budgetPeriodDateFormatter.string(from: beforeDate)
            let dayBeforeLastDateString = BudgetPeriod.budgetPeriodDateFormatter.string(from: dayBeforeLastDate)
            
            // Filter for other days except first day of transaction list. All transactions will be considered before beforeDate (one day before first day). This means we dont need to consider transactionIDs here.
            let filterPredicate = NSPredicate(format: #keyPath(BudgetPeriod.startDateString) + " <= %@ ", argumentArray: [dayBeforeLastDateString])
            
            // First day filter. For the first date in transaction list, the day should be equal to first day and transactionID should be after first transaction ID (beforeID).
            let firstDayFilterPredicate = NSPredicate(format: #keyPath(BudgetPeriod.startDateString) + " == %@ && " + #keyPath(BudgetPeriod.budgetPeriodID) + " <= %@ ", argumentArray: [fromDateString, beforeID])
            
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [filterPredicate, firstDayFilterPredicate]))
        }
        
        if let budgetID = budgetID {
            predicates.append(NSPredicate(format: #keyPath(BudgetPeriod.budgetID) + " == %ld", argumentArray: [budgetID]))
        }
        
        if let fromDate = fromDate {
            predicates.append(NSPredicate(format: #keyPath(BudgetPeriod.startDateString) + " >= %@", argumentArray: [BudgetPeriod.budgetPeriodDateFormatter.string(from: fromDate)]))
        }
        
        if let toDate = toDate {
            predicates.append(NSPredicate(format: #keyPath(BudgetPeriod.startDateString) + " <= %@", argumentArray: [BudgetPeriod.budgetPeriodDateFormatter.string(from: toDate)]))
        }
        
        if let status = status {
            predicates.append(NSPredicate(format: #keyPath(BudgetPeriod.budget.statusRawValue) + " == %@", argumentArray: [status.rawValue]))
        }
        
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: BudgetPeriod.self, objectsResponse: budgetPeriodsResponse, primaryKey: #keyPath(BudgetPeriod.budgetPeriodID), linkedKeys: [\BudgetPeriod.budgetID], filterPredicate: filterPredicate, managedObjectContext: managedObjectContext)
        
        if let budgetIDs = updatedLinkedIDs[\BudgetPeriod.budgetID] {
            linkingBudgetIDs = linkingBudgetIDs.union(budgetIDs)
        }
        
        budgetPeriodsLock.lock()
        
        defer {
            budgetPeriodsLock.unlock()
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func removeCachedBudget(budgetID: Int64) {
        budgetsLock.lock()
        
        defer {
            budgetsLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: Budget.self, id: budgetID, primaryKey: #keyPath(Budget.budgetID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
}
