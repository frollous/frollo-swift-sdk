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

protocol CachedObjects {
    
    func cachedObject<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, objectID: Int64, objectKey: String) -> T?
    func cachedObjects<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?) -> [T]?
    func fetchedResultsController<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, batchSize: Int?, limit: Int?, sectionNameKeypath: String?) -> NSFetchedResultsController<T>
    
}

extension CachedObjects {
    
    internal func cachedObject<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, objectID: Int64, objectKey: String) -> T? {
        var fetchedObject: T?
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            fetchRequest.predicate = NSPredicate(format: objectKey + " == %ld", argumentArray: [objectID])
            
            do {
                let fetchedObjects = try context.fetch(fetchRequest)
                
                fetchedObject = fetchedObjects.first
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return fetchedObject
    }
    
    func cachedObjects<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?) -> [T]? {
        var fetchedObjects: [T]?
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
            
            if let fetchLimit = limit {
                fetchRequest.fetchLimit = fetchLimit
            }
            
            do {
                fetchedObjects = try context.fetch(fetchRequest)
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return fetchedObjects
    }
    
    internal func fetchedResultsController<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, batchSize: Int? = nil, limit: Int?, sectionNameKeypath: String? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        if let fetchLimit = limit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        if let fetchBatchSize = batchSize {
            fetchRequest.fetchBatchSize = fetchBatchSize
        }
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeypath, cacheName: nil)
    }
    
}
