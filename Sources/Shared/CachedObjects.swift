//
//  CachedObjects.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 24/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

protocol CachedObjects {
    
    func cachedObject<T: CacheableManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, objectID: Int64, objectKey: String) -> T?
    func cachedObjects<T: CacheableManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]?
    func fetchedResultsController<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> NSFetchedResultsController<T>
    
}

extension CachedObjects {
    
    internal func cachedObject<T: CacheableManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, objectID: Int64, objectKey: String) -> T? {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSPredicate(format: objectKey + " == %ld", argumentArray: [objectID])
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            
            return fetchedObjects.first
        } catch {
            Log.error(error.localizedDescription)
        }
        
        return nil
    }
    
    func cachedObjects<T: CacheableManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]? {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            Log.error(error.localizedDescription)
        }
        
        return nil
    }
    
    internal func fetchedResultsController<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
}
