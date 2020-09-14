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

/**
 Images
 
 Manages caching and refreshing of images
 */
public class Images: CachedObjects, ResponseHandler {
    
    private let database: Database
    private let service: APIService
    
    private let imageLock = NSLock()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    // MARK: - Images
    
    /**
     Fetch image by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - imageID: Unique image ID to fetch
     */
    public func image(context: NSManagedObjectContext, imageID: Int64) -> Image? {
        return cachedObject(type: Image.self, context: context, objectID: imageID, objectKey: #keyPath(Image.imageID))
    }
    
    /**
     Fetch images from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - imageTypes: Array of image types to find matching Images for (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Image` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to imageID ascending (Optional)
     */
    public func images(context: NSManagedObjectContext,
                       imageTypes: [String]? = nil,
                       unread: Bool? = nil,
                       filteredBy predicate: NSPredicate? = nil,
                       sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Image.imageID), ascending: true)],
                       limit: Int? = nil) -> [Image]? {
        var predicates = [NSPredicate]()
        if let types = imageTypes {
            var imageTypePredicates = [NSPredicate]()
            
            for type in types {
                imageTypePredicates.append(NSPredicate(format: #keyPath(Image.typesRawValue) + " CONTAINS %@", argumentArray: ["|" + type + "|"]))
            }
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: imageTypePredicates)
            predicates.append(compoundPredicate)
        }
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Image.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of Images from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - imageTypes: Array of image types to find matching Images for (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Image` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to imageID ascending (Optional)
     */
    public func imagesFetchedResultsController(context: NSManagedObjectContext,
                                               imageTypes: [String]? = nil,
                                               unread: Bool? = nil,
                                               filteredBy predicate: NSPredicate? = nil,
                                               sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Image.imageID), ascending: true)],
                                               limit: Int? = nil) -> NSFetchedResultsController<Image>? {
        var predicates = [NSPredicate]()
        if let types = imageTypes {
            var imageTypePredicates = [NSPredicate]()
            
            for type in types {
                imageTypePredicates.append(NSPredicate(format: #keyPath(Image.typesRawValue) + " CONTAINS %@", argumentArray: ["|" + type + "|"]))
            }
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: imageTypePredicates)
            predicates.append(compoundPredicate)
        }
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Image.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available images from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshImages(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchImages { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleImagesResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleImageResponse(_ imageResponse: APIImageResponse, managedObjectContext: NSManagedObjectContext) {
        imageLock.lock()
        
        defer {
            imageLock.unlock()
        }
        
        updateObjectWithResponse(type: Image.self, objectResponse: imageResponse, primaryKey: #keyPath(Image.imageID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleImagesResponse(_ imagesResponse: [APIImageResponse], managedObjectContext: NSManagedObjectContext) {
        imageLock.lock()
        
        defer {
            imageLock.unlock()
        }
        
        updateImageObjectsWithResponse(imagesResponse, filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func updateImageObjectsWithResponse(_ imagesResponse: [APIImageResponse], filterPredicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) {
        // Sort by ID
        let sortedObjectResponses = imagesResponse.sorted(by: { (responseA: APIImageResponse, responseB: APIImageResponse) -> Bool in
            responseB.id > responseA.id
        })
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
            
            var predicates = [NSPredicate(format: #keyPath(Image.imageID) + " IN %@", argumentArray: [objectIDs])]
            
            if let filter = filterPredicate {
                predicates.append(filter)
            }
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Image.imageID), ascending: true)]
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for objectResponse in sortedObjectResponses {
                    var object: Image
                    
                    if index < existingObjects.count, existingObjects[index].primaryID == objectResponse.id {
                        object = existingObjects[index]
                        index += 1
                    } else {
                        object = Image(context: managedObjectContext)
                    }
                    
                    object.update(response: objectResponse, context: managedObjectContext)
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<Image> = Image.fetchRequest()
                
                var deletePredicates = [NSPredicate(format: "NOT " + #keyPath(Image.imageID) + " IN %@", argumentArray: [objectIDs])]
                
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
    }
    
}
