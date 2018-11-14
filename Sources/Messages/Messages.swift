//
//  Messages.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

public class Messages: CachedObjects, ResponseHandler {
    
    private let database: Database
    private let network: Network
    
    private let messageLock = NSLock()
    
    internal init(database: Database, network: Network) {
        self.database = database
        self.network = network
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
    
    public func refreshMessages(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchMessages { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let messagesResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessagesResponse(messagesResponse, unread: false, managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    public func refreshMessage(messageID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchMessage(messageID: messageID) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let messageResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessageResponse(messageResponse, managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    public func updateMessage(messageID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        guard let message = message(context: database.newBackgroundContext(), messageID: messageID)
            else {
                let error = DataError(type: .database, subType: .notFound)
                
                DispatchQueue.main.async {
                    completion?(error)
                }
                return
        }
        
        let request = message.updateRequest()
        
        network.updateMessage(messageID: messageID, request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let messageResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessageResponse(messageResponse, managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    public func refreshUnreadMessages(completion: FrolloSDKCompletionHandler? = nil) {
        network.fetchUnreadMessages { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            } else {
                if let messagesResponse = response {
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleMessagesResponse(messagesResponse, unread: true, managedObjectContext: managedObjectContext)
                }
            }
            
            DispatchQueue.main.async {
                completion?(error)
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
            case .html5:
                type = MessageHTML.self
            case .textAndImage:
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
            return responseB.id > responseA.id
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
                    
                    if index < existingObjects.count && existingObjects[index].primaryID == objectResponse.id {
                        object = existingObjects[index]
                        index += 1
                    } else {
                        switch objectResponse.contentType {
                            case .html5:
                                object = MessageHTML(context: managedObjectContext)
                            case .textAndImage:
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
