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
    
    internal init(database: Database) {
        self.database = database
    }
    
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
        - budgetType: Filter by type of the budget (optional)
        - typeValue: Filter by  type value of the budget (optional). budget category name, category ID or merchant ID
        - current: Filter budgets by current budget. Defaults to current budget = true (Optional)
        - frequency: Filter by frequency of the budget (optional)
        - status: Filter by status of the budget (optional)
        - trackingStatus: Filter by tracking status of the budget (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Budget` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to budgetID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func budgets(context: NSManagedObjectContext,
                        current: Bool? = true,
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
        - current: Filter budgets by current budget. Defaults to current budget = true (Optional)
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
                                                current: Bool? = true,
                                                budgetType: Budget.BudgetType? = nil,
                                                typeValue: String? = nil,
                                                frequency: Budget.Frequency? = nil,
                                                status: Budget.Status? = nil,
                                                trackingStatus: Budget.TrackingStatus? = nil,
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
}
