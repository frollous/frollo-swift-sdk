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

/// Mangages challenges and user challenge tracking
public class Challenges: CachedObjects, ResponseHandler {
    
    private let database: Database
    private let service: APIService
    
    internal let challengeLock = NSLock()
    internal let userChallengeLock = NSLock()
    
    private var linkingChallengeIDs = Set<Int64>()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    // MARK: - Challenges
    
    /**
     Fetch challenge by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - challengeID: Unique challenge ID to fetch
     */
    public func challenge(context: NSManagedObjectContext, challengeID: Int64) -> Challenge? {
        return cachedObject(type: Challenge.self, context: context, objectID: challengeID, objectKey: #keyPath(Challenge.challengeID))
    }
    
    /**
     Fetch challenges from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Challenge` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to challengeID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func challenges(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Challenge.challengeID), ascending: true)], limit: Int? = nil) -> [Challenge]? {
        return cachedObjects(type: Challenge.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Challenges from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - filteredBy: Predicate of properties to match for fetching. See `Challenge` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to challengeID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func challengesFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Challenge.challengeID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<Challenge>? {
        return fetchedResultsController(type: Challenge.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available challenges from the host.
     
     Includes user created and system challenges
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails67
     */
    public func refreshChallenges(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchChallenges { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleChallengesResponse(response, managedObjectContext: managedObjectContext)
                    
                    //self.linkUserChallengesToChallenges()
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific challenge by ID from the host
     
     - parameters:
        - challengeID: ID of the challenge to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshChallenge(challengeID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchChallenge(challengeID: challengeID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleChallengeResponse(response, managedObjectContext: managedObjectContext)
                    
                    //self.linkUserChallengesToChallenges()
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - User Challenges
    
    /**
     Fetch user challenge by ID from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - userChallengeID: Unique user challenge ID to fetch
     */
    public func userChallenge(context: NSManagedObjectContext, userChallengeID: Int64) -> UserChallenge? {
        return cachedObject(type: UserChallenge.self, context: context, objectID: userChallengeID, objectKey: #keyPath(UserChallenge.userChallengeID))
    }
    
    /**
     Fetch user challenges from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - filteredBy: Predicate of properties to match for fetching. See `UserChallenge` for properties (Optional)
     - sortedBy: Array of sort descriptors to sort the results by. Defaults to userChallengeID ascending (Optional)
     - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func userChallenges(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(UserChallenge.userChallengeID), ascending: true)], limit: Int? = nil) -> [UserChallenge]? {
        return cachedObjects(type: UserChallenge.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of User Challenges from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - filteredBy: Predicate of properties to match for fetching. See `UserChallenge` for properties (Optional)
     - sortedBy: Array of sort descriptors to sort the results by. Defaults to userChallengeID ascending (Optional)
     - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func userChallengesFetchedResultsController(context: NSManagedObjectContext, filteredBy predicate: NSPredicate? = nil, sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(UserChallenge.userChallengeID), ascending: true)], limit: Int? = nil) -> NSFetchedResultsController<UserChallenge>? {
        return fetchedResultsController(type: UserChallenge.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available user challenges from the host.
     
     Includes all challenge statuses
     
     - parameters:
     - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshUserChallenges(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchUserChallenges { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleUserChallengesResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkUserChallengesToChallenges(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific user challenge by ID from the host
     
     - parameters:
     - userChallengeID: ID of the user challenge to fetch
     - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshUserChallenge(userChallengeID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchUserChallenge(userChallengeID: userChallengeID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleUserChallengeResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkUserChallengesToChallenges(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkUserChallengesToChallenges(managedObjectContext: NSManagedObjectContext) {
        challengeLock.lock()
        userChallengeLock.lock()
        
        defer {
            challengeLock.unlock()
            userChallengeLock.unlock()
        }
        
        linkObjectToParentObject(type: UserChallenge.self, parentType: Challenge.self, managedObjectContext: managedObjectContext, linkedIDs: linkingChallengeIDs, linkedKey: \UserChallenge.challengeID, linkedKeyName: #keyPath(UserChallenge.challengeID))
        
        linkingChallengeIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    internal func handleChallengeResponse(_ challengeResponse: APIChallengeResponse, linkedGoal: Goal? = nil, managedObjectContext: NSManagedObjectContext) {
        challengeLock.lock()
        
        defer {
            challengeLock.unlock()
        }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: #keyPath(Challenge.challengeID) + " == %ld", argumentArray: [challengeResponse.id])
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                let object: Challenge
                if let existingObject = existingObjects.first {
                    object = existingObject
                } else {
                    object = Challenge(context: managedObjectContext)
                }
                
                object.update(response: challengeResponse, context: managedObjectContext)
                
                if let goal = linkedGoal {
                    object.addToGoals(goal)
                }
            } catch {
                Log.error(error.localizedDescription)
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
    
    private func handleChallengesResponse(_ challengesResponse: [APIChallengeResponse], managedObjectContext: NSManagedObjectContext) {
        challengeLock.lock()
        
        defer {
            challengeLock.unlock()
        }
        
        updateObjectsWithResponse(type: Challenge.self, objectsResponse: challengesResponse, primaryKey: #keyPath(Challenge.challengeID), linkedKeys: [], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleUserChallengeResponse(_ challengeResponse: APIUserChallengeResponse, managedObjectContext: NSManagedObjectContext) {
        userChallengeLock.lock()
        
        defer {
            userChallengeLock.unlock()
        }
        
        updateObjectWithResponse(type: UserChallenge.self, objectResponse: challengeResponse, primaryKey: #keyPath(UserChallenge.userChallengeID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleUserChallengesResponse(_ userChallengesResponse: [APIUserChallengeResponse], managedObjectContext: NSManagedObjectContext) {
        userChallengeLock.lock()
        
        defer {
            userChallengeLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: UserChallenge.self, objectsResponse: userChallengesResponse, primaryKey: #keyPath(UserChallenge.userChallengeID), linkedKeys: [\UserChallenge.challengeID], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        if let challengeIDs = updatedLinkedIDs[\UserChallenge.challengeID] {
            linkingChallengeIDs = linkingChallengeIDs.union(challengeIDs)
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
