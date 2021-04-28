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
        - imageType: Optional image type to filter by
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshImages(imageType: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchImages(imageType: imageType) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
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
                error.logError()
            }
        }
    }
    
    private func handleImagesResponse(_ imagesResponse: [APIImageResponse], managedObjectContext: NSManagedObjectContext) {
        imageLock.lock()
        
        defer {
            imageLock.unlock()
        }
        
        updateObjectsWithResponse(type: Image.self, objectsResponse: imagesResponse, primaryKey: #keyPath(Image.imageID), linkedKeys: [], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
}
