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
 Messages
 
 Manages caching and refreshing of messages
 */
public class Messages: CachedObjects, ResponseHandler {
    
    internal weak var delegate: FrolloSDKDelegate?
    
    private let authentication: Authentication
    private let database: Database
    private let service: APIService
    
    private let messageLock = NSLock()
    
    internal init(database: Database, service: APIService, authentication: Authentication) {
        self.authentication = authentication
        self.database = database
        self.service = service
    }
    
    // MARK: - Messages
    
    /**
     Fetch message by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - messageID: Unique message ID to fetch
     */
    public func message(context: NSManagedObjectContext, messageID: Int64) -> Message? {
        return cachedObject(type: Message.self, context: context, objectID: messageID, objectKey: #keyPath(Message.messageID))
    }
    
    /**
     Fetch messages from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - contentType: Filter the message by the type of content it contains (optional)
        - messageTypes: Array of message types to find matching Messages for (optional)
        - unread: Only return messages that are read or unread (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Message` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to messageID ascending (Optional)
     */
    public func messages(context: NSManagedObjectContext,
                         contentType: Message.ContentType? = nil,
                         messageTypes: [String]? = nil,
                         unread: Bool? = nil,
                         filteredBy predicate: NSPredicate? = nil,
                         sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Message.messageID), ascending: true)],
                         limit: Int? = nil) -> [Message]? {
        var predicates = [NSPredicate]()
        if let type = contentType {
            predicates.append(NSPredicate(format: #keyPath(Message.contentTypeRawValue) + " == %@", argumentArray: [type.rawValue]))
        }
        if let types = messageTypes {
            var messageTypePredicates = [NSPredicate]()
            
            for type in types {
                messageTypePredicates.append(NSPredicate(format: #keyPath(Message.typesRawValue) + " CONTAINS %@", argumentArray: ["|" + type + "|"]))
            }
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: messageTypePredicates)
            predicates.append(compoundPredicate)
        }
        if let unreadFilter = unread {
            predicates.append(NSPredicate(format: #keyPath(Message.read) + " == %ld", argumentArray: [!unreadFilter]))
        }
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Message.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Returns the count of messages from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - unread: Only return messages that are read or unread (optional)
     - messageTypes: Array of message types to find matching Messages for (optional)
     - filteredBy: Predicate of properties to match for fetching. See `Message` for properties (Optional)
     
     */
    public func messagesCount(context: NSManagedObjectContext,
                              unread: Bool? = nil,
                              messageTypes: [String]? = nil,
                              filteredBy predicate: NSPredicate? = nil) -> Int? {
        
        var predicates = [NSPredicate]()
        
        if let types = messageTypes {
            
            let messageTypePredicates = types.map { (value) -> NSPredicate in
                NSPredicate(format: #keyPath(Message.typesRawValue) + " CONTAINS %@", argumentArray: ["|" + value + "|"])
            }
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: messageTypePredicates)
            predicates.append(compoundPredicate)
        }
        
        if let unreadFilter = unread {
            predicates.append(NSPredicate(format: #keyPath(Message.read) + " == %ld", argumentArray: [!unreadFilter]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            Log.error(error.localizedDescription)
            return nil
        }
        
    }
    
    /**
     Fetched results controller of Messages from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - contentType: Filter the message by the type of content it contains (optional)
        - messageTypes: Array of message types to find matching Messages for (optional)
        - unread: Only return messages that are read or unread (optional)
        - filteredBy: Predicate of properties to match for fetching. See `Message` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to messageID ascending (Optional)
     */
    public func messagesFetchedResultsController(context: NSManagedObjectContext,
                                                 contentType: Message.ContentType? = nil,
                                                 messageTypes: [String]? = nil,
                                                 unread: Bool? = nil,
                                                 filteredBy predicate: NSPredicate? = nil,
                                                 sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Message.messageID), ascending: true)],
                                                 limit: Int? = nil) -> NSFetchedResultsController<Message>? {
        var predicates = [NSPredicate]()
        if let type = contentType {
            predicates.append(NSPredicate(format: #keyPath(Message.contentTypeRawValue) + " == %@", argumentArray: [type.rawValue]))
        }
        if let types = messageTypes {
            var messageTypePredicates = [NSPredicate]()
            
            for type in types {
                messageTypePredicates.append(NSPredicate(format: #keyPath(Message.typesRawValue) + " CONTAINS %@", argumentArray: ["|" + type + "|"]))
            }
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: messageTypePredicates)
            predicates.append(compoundPredicate)
        }
        if let unreadFilter = unread {
            predicates.append(NSPredicate(format: #keyPath(Message.read) + " == %ld", argumentArray: [!unreadFilter]))
        }
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Message.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh all available messages from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshMessages(completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.fetchMessages { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessagesResponse(response, unread: false, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific message by ID from the host
     
     - parameters:
        - messageID: ID of the message to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshMessage(messageID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.fetchMessage(messageID: messageID) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessageResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a message on the host
     
     - parameters:
        - messageID: ID of the message to be updated
        - completion: Optional completion handler with optional error if the request fails
     */
    public func updateMessage(messageID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        guard let message = message(context: managedObjectContext, messageID: messageID)
        else {
            let error = DataError(type: .database, subType: .notFound)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        var request: APIMessageUpdateRequest!
        
        managedObjectContext.performAndWait {
            request = message.updateRequest()
        }
        
        service.updateMessage(messageID: messageID, request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessageResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh all unread messages from the host.
     
     - parameters:
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshUnreadMessages(completion: FrolloSDKCompletionHandler? = nil) {
        guard authentication.loggedIn
        else {
            let error = DataError(type: .authentication, subType: .loggedOut)
            
            Log.error(error.localizedDescription)
            
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        service.fetchUnreadMessages { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessagesResponse(response, unread: true, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Push Notification Handling
    
    internal func handleMessageNotification(_ notification: NotificationPayload) {
        guard let messageID = notification.userMessageID
        else {
            return
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        if message(context: managedObjectContext, messageID: messageID) == nil {
            refreshMessage(messageID: messageID) { result in
                switch result {
                    case .failure(let error):
                        Log.error(error.localizedDescription)
                    case .success:
                        DispatchQueue.main.async { [weak self] in
                            self?.delegate?.messageReceived(messageID)
                        }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.delegate?.messageReceived(messageID)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleMessageResponse(_ messageResponse: APIMessageResponse, managedObjectContext: NSManagedObjectContext) {
        messageLock.lock()
        
        defer {
            messageLock.unlock()
        }
        
        let type: Message.Type
        switch messageResponse.contentType {
            case .html:
                type = MessageHTML.self
            case .image:
                type = MessageImage.self
            case .text:
                type = MessageText.self
            case .video:
                type = MessageText.self
        }
        
        updateObjectWithResponse(type: type, objectResponse: messageResponse, primaryKey: #keyPath(Message.messageID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func handleMessagesResponse(_ messagesResponse: [APIMessageResponse], unread: Bool, managedObjectContext: NSManagedObjectContext) {
        messageLock.lock()
        
        defer {
            messageLock.unlock()
        }
        
        var filterPredicate: NSPredicate?
        if unread {
            filterPredicate = NSPredicate(format: #keyPath(Message.read) + " == false", argumentArray: nil)
        }
        
        updateMessageObjectsWithResponse(messagesResponse, filterPredicate: filterPredicate, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func updateMessageObjectsWithResponse(_ messagesResponse: [APIMessageResponse], filterPredicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) {
        // Sort by ID
        let sortedObjectResponses = messagesResponse.sorted(by: { (responseA: APIMessageResponse, responseB: APIMessageResponse) -> Bool in
            responseB.id > responseA.id
        })
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
            
            var predicates = [NSPredicate(format: #keyPath(Message.messageID) + " IN %@", argumentArray: [objectIDs])]
            
            if let filter = filterPredicate {
                predicates.append(filter)
            }
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.messageID), ascending: true)]
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for objectResponse in sortedObjectResponses {
                    var object: Message
                    
                    if index < existingObjects.count, existingObjects[index].primaryID == objectResponse.id {
                        object = existingObjects[index]
                        index += 1
                    } else {
                        switch objectResponse.contentType {
                            case .html:
                                object = MessageHTML(context: managedObjectContext)
                            case .image:
                                object = MessageImage(context: managedObjectContext)
                            case .text:
                                object = MessageText(context: managedObjectContext)
                            case .video:
                                object = MessageVideo(context: managedObjectContext)
                        }
                    }
                    
                    object.update(response: objectResponse, context: managedObjectContext)
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<Message> = Message.fetchRequest()
                
                var deletePredicates = [NSPredicate(format: "NOT " + #keyPath(Message.messageID) + " IN %@", argumentArray: [objectIDs])]
                
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
