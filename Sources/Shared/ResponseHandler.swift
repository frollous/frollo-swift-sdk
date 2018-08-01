//
//  ResponseHandler.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

protocol ResponseHandler {
    
    func updateObjectsWithResponse<T: CacheableManagedObject & NSManagedObject>(type: T.Type, objectsResponse: [APIUniqueResponse], primaryKey: String, filterPredicate: NSPredicate, managedObjectContext: NSManagedObjectContext)

}

extension ResponseHandler {
    
    /**
     Some of that crazy voodoo shit
    */
    internal func updateObjectsWithResponse<T: CacheableManagedObject>(type: T.Type, objectsResponse: [APIUniqueResponse], primaryKey: String, filterPredicate: NSPredicate, managedObjectContext: NSManagedObjectContext) where T: NSManagedObject {
        // Sort by ID
        let sortedObjectResponses = objectsResponse.sorted(by: { (responseA: APIUniqueResponse, responseB: APIUniqueResponse) -> Bool in
            return responseA.id > responseB.id
        })
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            
            let predicate = NSPredicate(format: primaryKey + " IN %@", argumentArray: [objectIDs])
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, filterPredicate])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: primaryKey, ascending: true)]
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for objectResponse in sortedObjectResponses {
                    var object: T
                    
                    if index < existingObjects.count && existingObjects[index].primaryID == objectResponse.id {
                        object = existingObjects[index]
                        index += 1
                    } else {
                        object = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: managedObjectContext) as! T
                    }
                    
                    object.update(response: objectResponse)
                    //updatedObjectIDs.insert(object.primaryID)
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
                
                let deletePredicate = NSPredicate(format: "NOT " + primaryKey + " IN %@", argumentArray: [objectIDs])
                
                deleteRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [deletePredicate, filterPredicate])
                
                do {
                    let deleteObjects = try managedObjectContext.fetch(deleteRequest)
                    
                    for deleteObject in deleteObjects {
                        managedObjectContext.delete(deleteObject)
                    }
                } catch let fetchError {
                    Log.error(fetchError.localizedDescription)
                }
            } catch let fetchError {
                Log.error(fetchError.localizedDescription)
            }
        }
    }
    
}
