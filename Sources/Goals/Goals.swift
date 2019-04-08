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

/// Manages goals and user goals tracking
public class Goals: CachedObjects, ResponseHandler {
    
    private let challenges: Challenges
    private let database: Database
    private let service: APIService
    
    private let goalLock = NSLock()
    private let userGoalLock = NSLock()
    
    private var linkingGoalIDs = Set<Int64>()
    
    internal init(database: Database, challenges: Challenges, service: APIService) {
        self.database = database
        self.challenges = challenges
        self.service = service
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
     Refresh all available goals from the host.
     
     Includes user created and system goals
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshGoals(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchGoals { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleGoalsResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkUserGoalsToGoals(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific goal by ID from the host
     
     - parameters:
        - goalID: ID of the goal to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshGoal(goalID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
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
                    
                    self.linkUserGoalsToGoals(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - User Goals
    
    /**
     Fetch user goal by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - userGoalID: Unique user goal ID to fetch
     */
    public func userGoal(context: NSManagedObjectContext, userGoalID: Int64) -> UserGoal? {
        return cachedObject(type: UserGoal.self, context: context, objectID: userGoalID, objectKey: #keyPath(UserGoal.userGoalID))
    }
    
    /**
     Fetch user goals from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `UserGoal` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to userGoalID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func userGoals(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(UserGoal.userGoalID), ascending: true)], limit: Int? = nil) -> [UserGoal]? {
        return cachedObjects(type: UserGoal.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of User Goals from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `UserGoal` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to userGoalID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func userGoalsFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(UserGoal.userGoalID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<UserGoal>? {
        return fetchedResultsController(type: UserGoal.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available user goals from the host.
     
     Includes all goal statuses
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshUserGoals(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchUserGoals { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleUserGoalsResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkUserGoalsToGoals(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific user goal by ID from the host
     
     - parameters:
        - userGoalID: ID of the user goal to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshUserGoal(userGoalID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchUserGoal(userGoalID: userGoalID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleUserGoalResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkUserGoalsToGoals(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkUserGoalsToGoals(managedObjectContext: NSManagedObjectContext) {
        goalLock.lock()
        userGoalLock.lock()
        
        defer {
            goalLock.unlock()
            userGoalLock.unlock()
        }
        
        linkObjectToParentObject(type: UserGoal.self, parentType: Goal.self, managedObjectContext: managedObjectContext, linkedIDs: linkingGoalIDs, linkedKey: \UserGoal.goalID, linkedKeyName: #keyPath(UserGoal.goalID))
        
        linkingGoalIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                Log.debug(error.debugDescription)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleGoalResponse(_ goalResponse: APIGoalResponse, managedObjectContext: NSManagedObjectContext) {
        goalLock.lock()
        
        defer {
            goalLock.unlock()
        }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: #keyPath(Goal.goalID) + " == %ld", argumentArray: [goalResponse.id])
            
            do {
                let existingGoals = try managedObjectContext.fetch(fetchRequest)
                
                let goal: Goal
                if let existingGoal = existingGoals.first {
                    goal = existingGoal
                } else {
                    goal = Goal(context: managedObjectContext)
                }
                
                goal.update(response: goalResponse, context: managedObjectContext)
                
                if let challengeResponses = goalResponse.suggestedChallenges {
                    for challengeResponse in challengeResponses {
                        challenges.handleChallengeResponse(challengeResponse, linkedGoal: goal, managedObjectContext: managedObjectContext)
                    }
                }
            } catch {
                Log.error(error.localizedDescription)
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                Log.debug(error.debugDescription)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleGoalsResponse(_ goalsResponse: [APIGoalResponse], managedObjectContext: NSManagedObjectContext) {
        goalLock.lock()
        
        defer {
            goalLock.unlock()
        }
        
        // Sort by ID
        let sortedGoalResponses = goalsResponse.sorted(by: { (responseA: APIUniqueResponse, responseB: APIUniqueResponse) -> Bool in
            responseB.id > responseA.id
        })
        
        // Build id list predicate
        let goalIDs = sortedGoalResponses.map { $0.id }
        
        managedObjectContext.performAndWait {
            // Fetch existing goals for updating
            let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: #keyPath(Goal.goalID) + " IN %@", argumentArray: [goalIDs])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Goal.goalID), ascending: true)]
            
            do {
                let existingGoals = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for goalResponse in sortedGoalResponses {
                    var goal: Goal
                    
                    if index < existingGoals.count, existingGoals[index].primaryID == goalResponse.id {
                        goal = existingGoals[index]
                        index += 1
                    } else {
                        goal = Goal(context: managedObjectContext)
                    }
                    
                    goal.update(response: goalResponse, context: managedObjectContext)
                    
                    if let challengeResponses = goalResponse.suggestedChallenges {
                        for challengeResponse in challengeResponses {
                            challenges.handleChallengeResponse(challengeResponse, linkedGoal: goal, managedObjectContext: managedObjectContext)
                        }
                    }
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "NOT " + #keyPath(Goal.goalID) + " IN %@", argumentArray: [goalIDs])
                
                do {
                    let deleteGoals = try managedObjectContext.fetch(deleteRequest)
                    
                    for deleteGoal in deleteGoals {
                        managedObjectContext.delete(deleteGoal)
                    }
                } catch let fetchError {
                    Log.error(fetchError.localizedDescription)
                }
            } catch let fetchError {
                Log.error(fetchError.localizedDescription)
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                Log.debug(error.debugDescription)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleUserGoalResponse(_ userGoalResponse: APIUserGoalResponse, managedObjectContext: NSManagedObjectContext) {
        userGoalLock.lock()
        
        defer {
            userGoalLock.unlock()
        }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<UserGoal> = UserGoal.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: #keyPath(UserGoal.userGoalID) + " == %ld", argumentArray: [userGoalResponse.id])
            
            do {
                let existingUserGoals = try managedObjectContext.fetch(fetchRequest)
                
                let userGoal: UserGoal
                if let existingUserGoal = existingUserGoals.first {
                    userGoal = existingUserGoal
                } else {
                    userGoal = UserGoal(context: managedObjectContext)
                }
                
                userGoal.update(response: userGoalResponse, context: managedObjectContext)
                
                linkingGoalIDs.insert(userGoal.goalID)
                
                if let userChallengeResponses = userGoalResponse.userChallenges {
                    for challengeResponse in userChallengeResponses {
                        challenges.handleUserChallengeResponse(challengeResponse, linkedUserGoal: userGoal, managedObjectContext: managedObjectContext)
                    }
                }
            } catch {
                Log.error(error.localizedDescription)
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                Log.debug(error.debugDescription)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleUserGoalsResponse(_ userGoalsResponse: [APIUserGoalResponse], managedObjectContext: NSManagedObjectContext) {
        userGoalLock.lock()
        
        defer {
            userGoalLock.unlock()
        }
        
        var goalIDs = Set<Int64>()
        
        // Sort by ID
        let sortedUserGoalResponses = userGoalsResponse.sorted(by: { (responseA: APIUniqueResponse, responseB: APIUniqueResponse) -> Bool in
            responseB.id > responseA.id
        })
        
        // Build id list predicate
        let userGoalIDs = sortedUserGoalResponses.map { $0.id }
        
        managedObjectContext.performAndWait {
            // Fetch existing userGoals for updating
            let fetchRequest: NSFetchRequest<UserGoal> = UserGoal.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: #keyPath(UserGoal.userGoalID) + " IN %@", argumentArray: [userGoalIDs])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(UserGoal.userGoalID), ascending: true)]
            
            do {
                let existingUserGoals = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for userGoalResponse in sortedUserGoalResponses {
                    var userGoal: UserGoal
                    
                    if index < existingUserGoals.count, existingUserGoals[index].primaryID == userGoalResponse.id {
                        userGoal = existingUserGoals[index]
                        index += 1
                    } else {
                        userGoal = UserGoal(context: managedObjectContext)
                    }
                    
                    userGoal.update(response: userGoalResponse, context: managedObjectContext)
                    
                    goalIDs.insert(userGoal.goalID)
                    
                    if let userChallengeResponses = userGoalResponse.userChallenges {
                        for userChallengeResponse in userChallengeResponses {
                            challenges.handleUserChallengeResponse(userChallengeResponse, linkedUserGoal: userGoal, managedObjectContext: managedObjectContext)
                        }
                    }
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<UserGoal> = UserGoal.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "NOT " + #keyPath(UserGoal.userGoalID) + " IN %@", argumentArray: [userGoalIDs])
                
                do {
                    let deleteUserGoals = try managedObjectContext.fetch(deleteRequest)
                    
                    for deleteUserGoal in deleteUserGoals {
                        managedObjectContext.delete(deleteUserGoal)
                    }
                } catch let fetchError {
                    Log.error(fetchError.localizedDescription)
                }
            } catch let fetchError {
                Log.error(fetchError.localizedDescription)
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                Log.debug(error.debugDescription)
                Log.error(error.localizedDescription)
            }
        }
        
        linkingGoalIDs = linkingGoalIDs.union(goalIDs)
    }
    
}
