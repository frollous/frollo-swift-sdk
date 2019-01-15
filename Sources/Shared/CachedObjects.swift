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
    
    func cachedObject<T: UniqueManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, objectID: Int64, objectKey: String) -> T?
    func cachedObjects<T: UniqueManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?) -> [T]?
    func fetchedResultsController<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?) -> NSFetchedResultsController<T>
    
}

extension CachedObjects {
    
    internal func cachedObject<T: UniqueManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, objectID: Int64, objectKey: String) -> T? {
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
    
    func cachedObjects<T: UniqueManagedObject & NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?) -> [T]? {
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
    
    internal func fetchedResultsController<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit: Int?) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        if let fetchLimit = limit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
}
