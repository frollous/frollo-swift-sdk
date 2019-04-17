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

protocol ResponseHandler {
    
    /**
     Link objects of with a parent object relationship to each other at the Core Data level
     
     - parameters:
         - type: Managed object with a unique identifier type to apply this operation to
         - parentType: Managed object with a unique identifier type to link the child objects to
         - objectFilterPredicate: Filter what child objects are fetched by this operation
         - parentFilterPredicate: Filter what parent objects are fetched by this operation
         - managedObjectContext: Managed object context to execute this operation on
         - linkedIDs: IDs of the parent object to be fetched and their related children (as determined by the `linkedKey` parameter)
         - linkedKey: Key path of the linked key on the child object
         - linkedKeyName: String representation of the linked key on the child object
     */
    func linkObjectToParentObject<T: UniqueManagedObject & NSManagedObject, U: UniqueManagedObject & NSManagedObject>(type: T.Type,
                                                                                                                      parentType: U.Type,
                                                                                                                      objectFilterPredicate: NSPredicate?,
                                                                                                                      parentFilterPredicate: NSPredicate?,
                                                                                                                      managedObjectContext: NSManagedObjectContext,
                                                                                                                      linkedIDs: Set<Int64>,
                                                                                                                      linkedKey: KeyPath<T, Int64>,
                                                                                                                      linkedKeyName: String) -> Set<Int64>
    
    func updateObjectWithResponse<T: UniqueManagedObject & NSManagedObject>(type: T.Type,
                                                                            objectResponse: APIUniqueResponse,
                                                                            primaryKey: String,
                                                                            managedObjectContext: NSManagedObjectContext)
    
    /**
     Update objects in the cache with server response
     
     Updates, creates and deletes objects in the cache based on the server response. Utilises unique identifiers on the managed object to determine what objects should exist in the cache.
     
     - parameters:
         - type: Managed object with a unique identifier type to apply this operation to
         - objectResponse: An array of unique JSON objects returned from the server
         - primaryKey: The primary key of the managed object
         - linkedKeys: An array of linked key paths to be returned indicating what objects need linking to parent objects
         - filterPredicate:  Filter what cached objects are fetched by this operation
         - managedObjectContext: Managed object context to execute this operation on
     */
    func updateObjectsWithResponse<T: UniqueManagedObject & NSManagedObject>(type: T.Type,
                                                                             objectsResponse: [APIUniqueResponse],
                                                                             primaryKey: String,
                                                                             linkedKeys: [KeyPath<T, Int64>],
                                                                             filterPredicate: NSPredicate?,
                                                                             managedObjectContext: NSManagedObjectContext) -> [KeyPath<T, Int64>: Set<Int64>]
    
}

extension ResponseHandler {
    
    internal func updateObjectWithResponse<T: UniqueManagedObject & NSManagedObject>(type: T.Type,
                                                                                     objectResponse: APIUniqueResponse,
                                                                                     primaryKey: String,
                                                                                     managedObjectContext: NSManagedObjectContext) {
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
    
    @discardableResult internal func updateObjectsWithResponse<T: UniqueManagedObject & NSManagedObject>(type: T.Type,
                                                                                                         objectsResponse: [APIUniqueResponse],
                                                                                                         primaryKey: String,
                                                                                                         linkedKeys: [KeyPath<T, Int64>],
                                                                                                         filterPredicate: NSPredicate?,
                                                                                                         managedObjectContext: NSManagedObjectContext) -> [KeyPath<T, Int64>: Set<Int64>] {
        // Sort by ID
        let sortedObjectResponses = objectsResponse.sorted(by: { (responseA: APIUniqueResponse, responseB: APIUniqueResponse) -> Bool in
            responseB.id > responseA.id
        })
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        var linkedIDs = [KeyPath<T, Int64>: Set<Int64>]()
        for linkedKey in linkedKeys {
            linkedIDs[linkedKey] = Set<Int64>()
        }
        
        managedObjectContext.performAndWait {
            // Fetch existing objects for updating
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
                    
                    if index < existingObjects.count, existingObjects[index].primaryID == objectResponse.id {
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
    
    @discardableResult internal func linkObjectToParentObject<T: NSManagedObject, U: UniqueManagedObject & NSManagedObject>(type: T.Type,
                                                                                                                            parentType: U.Type,
                                                                                                                            objectFilterPredicate: NSPredicate? = nil,
                                                                                                                            parentFilterPredicate: NSPredicate? = nil,
                                                                                                                            managedObjectContext: NSManagedObjectContext,
                                                                                                                            linkedIDs: Set<Int64>,
                                                                                                                            linkedKey: KeyPath<T, Int64>,
                                                                                                                            linkedKeyName: String) -> Set<Int64> {
        var missingLinkedIDs = Set<Int64>()
        
        managedObjectContext.performAndWait {
            var objectPredicates = [NSPredicate(format: linkedKeyName + " IN %@", argumentArray: [linkedIDs])]
            if let filterPredicate = objectFilterPredicate {
                objectPredicates.append(filterPredicate)
            }
            
            let objectFetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            objectFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: objectPredicates)
            objectFetchRequest.sortDescriptors = [NSSortDescriptor(key: linkedKeyName, ascending: true)]
            
            do {
                let objects = try managedObjectContext.fetch(objectFetchRequest)
                
                var parentObjectPredicates = [NSPredicate(format: U.primaryKey + " IN %@", argumentArray: [linkedIDs])]
                if let filterPredicate = parentFilterPredicate {
                    parentObjectPredicates.append(filterPredicate)
                }
                
                let parentObjectFetchRequest: NSFetchRequest<U> = U.fetchRequest() as! NSFetchRequest<U>
                parentObjectFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: parentObjectPredicates)
                parentObjectFetchRequest.sortDescriptors = [NSSortDescriptor(key: U.primaryKey, ascending: true)]
                
                let parentObjects = try managedObjectContext.fetch(parentObjectFetchRequest)
                
                var currentParentObjectIndex = 0
                var matchedParentObjectIDs = Set<Int64>()
                
                for object in objects {
                    if currentParentObjectIndex >= parentObjects.count {
                        // Run out of matching provider IDs
                        continue
                    }
                    
                    var parentObject = parentObjects[currentParentObjectIndex]
                    if parentObject.primaryID != object[keyPath: linkedKey] {
                        for index in currentParentObjectIndex...(parentObjects.count - 1) {
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
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        return missingLinkedIDs
    }
    
}
