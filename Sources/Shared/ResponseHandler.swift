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
    
    func linkObjectToParentObject<T: CacheableManagedObject & NSManagedObject, U: CacheableManagedObject & NSManagedObject>(type: T.Type, parentType: U.Type, managedObjectContext: NSManagedObjectContext, linkedIDs: Set<Int64>, linkedKey: KeyPath<T, Int64>, linkedKeyName: String) -> Set<Int64>
    func updateObjectWithResponse<T: CacheableManagedObject & NSManagedObject>(type: T.Type, objectResponse: APIUniqueResponse, primaryKey: String, managedObjectContext: NSManagedObjectContext)
    func updateObjectsWithResponse<T: CacheableManagedObject & NSManagedObject>(type: T.Type, objectsResponse: [APIUniqueResponse], primaryKey: String, linkedKeys: [KeyPath<T, Int64>], filterPredicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) -> [KeyPath<T, Int64>: Set<Int64>]

}

extension ResponseHandler {
    
    internal func updateObjectWithResponse<T: CacheableManagedObject & NSManagedObject>(type: T.Type, objectResponse: APIUniqueResponse, primaryKey: String, managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            fetchRequest.predicate = NSPredicate(format: primaryKey + " == %ld", argumentArray: [objectResponse.id])
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                let object: T
                if let existingObject = existingObjects.first {
                    object = existingObject
                } else {
                    object = T(context: managedObjectContext)
                }
                
                object.update(response: objectResponse, context: managedObjectContext)
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    /**
     Some of that crazy voodoo shit
    */
    @discardableResult internal func updateObjectsWithResponse<T: CacheableManagedObject & NSManagedObject>(type: T.Type, objectsResponse: [APIUniqueResponse], primaryKey: String, linkedKeys: [KeyPath<T, Int64>], filterPredicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) -> [KeyPath<T, Int64>: Set<Int64>] {
        // Sort by ID
        let sortedObjectResponses = objectsResponse.sorted(by: { (responseA: APIUniqueResponse, responseB: APIUniqueResponse) -> Bool in
            return responseA.id > responseB.id
        })
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        var linkedIDs = [KeyPath<T, Int64>: Set<Int64>]()
        for linkedKey in linkedKeys {
            linkedIDs[linkedKey] = Set<Int64>()
        }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            
            var predicates = [NSPredicate(format: primaryKey + " IN %@", argumentArray: [objectIDs])]
            
            if let filter = filterPredicate {
                predicates.append(filter)
            }
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
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
                        object = T(context: managedObjectContext)
                    }
                    
                    object.update(response: objectResponse, context: managedObjectContext)
                    for linkedKey in linkedKeys {
                        linkedIDs[linkedKey]?.insert(object[keyPath: linkedKey])
                    }
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
                
                var deletePredicates = [NSPredicate(format: "NOT " + primaryKey + " IN %@", argumentArray: [objectIDs])]
                
                if let filter = filterPredicate {
                    deletePredicates.append(filter)
                }
                
                deleteRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: deletePredicates)
                
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
        
        return linkedIDs
    }
    
    @discardableResult internal func linkObjectToParentObject<T: CacheableManagedObject & NSManagedObject, U: CacheableManagedObject & NSManagedObject>(type: T.Type, parentType: U.Type, managedObjectContext: NSManagedObjectContext, linkedIDs: Set<Int64>, linkedKey: KeyPath<T, Int64>, linkedKeyName: String) -> Set<Int64> {
        var missingLinkedIDs = Set<Int64>()
        
        managedObjectContext.performAndWait {
            let objectFetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            objectFetchRequest.predicate = NSPredicate(format: linkedKeyName + " IN %@", linkedIDs)
            objectFetchRequest.sortDescriptors = [NSSortDescriptor(key: linkedKeyName, ascending: true)]
            
            let objects = try! managedObjectContext.fetch(objectFetchRequest)
            
            let parentObjectFetchRequest: NSFetchRequest<U> = U.fetchRequest() as! NSFetchRequest<U>
            parentObjectFetchRequest.predicate = NSPredicate(format: linkedKeyName + " IN %@", linkedIDs)
            parentObjectFetchRequest.sortDescriptors = [NSSortDescriptor(key: linkedKeyName, ascending: true)]
            
            let parentObjects = try! managedObjectContext.fetch(parentObjectFetchRequest)
            
            var currentParentObjectIndex = 0
            var matchedParentObjectIDs = Set<Int64>()
            
            for object in objects {
                if currentParentObjectIndex >= parentObjects.count {
                    // Run out of matching provider IDs
                    continue
                }
                
                var parentObject = parentObjects[currentParentObjectIndex]
                if parentObject.primaryID != object[keyPath: linkedKey] {
                    for index in currentParentObjectIndex...(parentObjects.count-1) {
                        parentObject = parentObjects[index]
                        
                        if parentObject.primaryID == object[keyPath: linkedKey] {
                            currentParentObjectIndex = index
                            
                            break
                        }
                    }
                }
                
                if parentObject.primaryID == object[keyPath: linkedKey] {
                    matchedParentObjectIDs.insert(parentObject.primaryID)
                    
                    parentObject.linkObject(object: object)
                }
            }
            
            missingLinkedIDs = linkedIDs.subtracting(matchedParentObjectIDs)
        }
        
        return missingLinkedIDs
    }
    
}
