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
    
    private let database: Database
    private let service: APIService
    
    private let goalsLock = NSLock()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    // MARK: - Goals
    
    /**
     Refresh all available goals from the host.
     
     Includes both estimated and confirmed goals.
     
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
                    
                    // self.linkUserGoalsToGoals()
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleGoalsResponse(_ goalsResponse: [APIGoalResponse], managedObjectContext: NSManagedObjectContext) {
        goalsLock.lock()
        
        defer {
            goalsLock.unlock()
        }
        
        updateObjectsWithResponse(type: Goal.self, objectsResponse: goalsResponse, primaryKey: #keyPath(Goal.goalID), linkedKeys: [], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
