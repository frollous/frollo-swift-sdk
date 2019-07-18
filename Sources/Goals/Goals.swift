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

/// Manages user goals and tracking
public class Goals: CachedObjects, ResponseHandler {
    
    private let authentication: Authentication
    private let database: Database
    private let service: APIService
    
    private let goalsLock = NSLock()
    
    internal init(database: Database, service: APIService, authentication: Authentication) {
        self.database = database
        self.service = service
        self.authentication = authentication
    }
    
    // MARK: - Goals
    
    /**
     Fetch goal by ID from the cache
     
     - parameters:
         - context: Managed object context to fetch these from; background or main thread
         - goalID: Unique goal ID to fetch
     */
    public func goal(context: NSManagedObjectContext, goalID: Int64) -> Goal? {
        return cachedObject(type: Goal.self, context: context, objectID: goalID, objectKey: #keyPath(Goal.goalID))
    }
    
    /**
     Fetch goals from the cache
     
     - parameters:
         - context: Managed object context to fetch these from; background or main thread
         - filteredBy: Predicate of properties to match for fetching. See `Goal` for properties (Optional)
         - sortedBy: Array of sort descriptors to sort the results by. Defaults to goalID ascending (Optional)
         - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func goals(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Goal.goalID), ascending: true)], limit: Int? = nil) -> [Goal]? {
        return cachedObjects(type: Goal.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Goals from the cache
     
     - parameters:
         - context: Managed object context to fetch these from; background or main thread
         - filteredBy: Predicate of properties to match for fetching. See `Goal` for properties (Optional)
         - sortedBy: Array of sort descriptors to sort the results by. Defaults to goalID ascending (Optional)
         - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func goalsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Goal.goalID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Goal>? {
        return fetchedResultsController(type: Goal.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh a specific goal by ID from the host
     
     - parameters:
         - goalID: ID of the goal to fetch
         - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshGoal(goalID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.fetchGoal(goalID: goalID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleGoalResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh all available goals from the host.
     
     Includes both estimated and confirmed goals.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshGoals(status: Goal.Status? = nil, trackingStatus: Goal.TrackingStatus? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.fetchGoals(status: status, trackingStatus: trackingStatus) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleGoalsResponse(response, status: status, trackingStatus: trackingStatus, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Create a new goal on the host
     
     - parameters:
         - name: Name of the goal
         - description: Additional description of the goal for the user (Optional)
         - imageURL: Image URL of an icon/picture associated with the goal (Optional)
         - type: Type of the goal (Optional)
         - subType: Sub type of the goal (Optional)
         - target: Target of the goal
         - trackingType: Tracking method the goal uses
         - frequency: Frequency of contributions to the goal
         - startDate: Start date of the goal. Defaults to today (Optional)
         - endDate: End date of the goal. Required for open ended and date based goals
         - periodAmount: Amount to be saved each period. Required for open ended and amount based goals
         - startAmount: Amount already contributed to a goal. Defaults to zero (Optional)
         - targetAmount: Target amount to reach for the goal. Required for amount and date based goals
         - completion: Optional completion handler with optional error if the request fails
     */
    public func createGoal(name: String,
                           description: String? = nil,
                           imageURL: URL? = nil,
                           type: String? = nil,
                           subType: String? = nil,
                           target: Goal.Target,
                           trackingType: Goal.TrackingType,
                           frequency: Goal.Frequency,
                           startDate: Date? = nil,
                           endDate: Date?,
                           periodAmount: Decimal?,
                           startAmount: Decimal = 0,
                           targetAmount: Decimal?,
                           accountID: Int64,
                           completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var endDateString: String?
        if let date = endDate {
            endDateString = Goal.goalDateFormatter.string(from: date)
        }
        var startDateString: String?
        if let date = startDate {
            startDateString = Goal.goalDateFormatter.string(from: date)
        }
        
        let request = APIGoalCreateRequest(accountID: accountID,
                                           description: description,
                                           endDate: endDateString,
                                           frequency: frequency,
                                           imageURL: imageURL?.absoluteString,
                                           name: name,
                                           periodAmount: (periodAmount as NSDecimalNumber?)?.stringValue,
                                           startAmount: (startAmount as NSDecimalNumber?)?.stringValue,
                                           startDate: startDateString,
                                           subType: subType,
                                           target: target,
                                           targetAmount: (targetAmount as NSDecimalNumber?)?.stringValue,
                                           trackingType: trackingType,
                                           type: type)
        
        guard request.valid()
        else {
            let error = DataError(type: .api, subType: .invalidData)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.createGoal(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleGoalResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Delete a specific goal by ID from the host
     
     - parameters:
        - goalID: ID of the goal to be deleted
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteGoal(goalID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.deleteGoal(goalID: goalID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedGoal(goalID: goalID)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    public func updateGoal(goalID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        guard let goal = goal(context: managedObjectContext, goalID: goalID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APIGoalUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = goal.updateRequest()
        }
        
        service.updateGoal(goalID: goalID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleGoalResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleGoalResponse(_ goalResponse: APIGoalResponse, managedObjectContext: NSManagedObjectContext) {
        goalsLock.lock()
        
        defer {
            goalsLock.unlock()
        }
        
        updateObjectWithResponse(type: Goal.self, objectResponse: goalResponse, primaryKey: #keyPath(Goal.goalID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleGoalsResponse(_ goalsResponse: [APIGoalResponse], status: Goal.Status?, trackingStatus: Goal.TrackingStatus?, managedObjectContext: NSManagedObjectContext) {
        goalsLock.lock()
        
        defer {
            goalsLock.unlock()
        }
        
        var predicates = [NSPredicate]()
        if let statusFilter = status {
            predicates.append(NSPredicate(format: #keyPath(Goal.statusRawValue) + " == %@", argumentArray: [statusFilter.rawValue]))
        }
        if let trackingStatusFilter = trackingStatus {
            predicates.append(NSPredicate(format: #keyPath(Goal.trackingStatusRawValue) + " == %@", argumentArray: [trackingStatusFilter.rawValue]))
        }
        
        var filterPredicate: NSPredicate?
        if !predicates.isEmpty {
            filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        updateObjectsWithResponse(type: Goal.self, objectsResponse: goalsResponse, primaryKey: #keyPath(Goal.goalID), linkedKeys: [], filterPredicate: filterPredicate, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func removeCachedGoal(goalID: Int64) {
        goalsLock.lock()
        
        defer {
            goalsLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: Goal.self, id: goalID, primaryKey: #keyPath(Goal.goalID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
