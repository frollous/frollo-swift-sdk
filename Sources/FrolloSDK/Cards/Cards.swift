//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreData
import Foundation

/// Managed all aspects of Cards
public class Cards: CachedObjects, ResponseHandler {
    
    private let aggregation: Aggregation
    private let service: APIService
    private let database: Database
    
    private let cardsLock = NSLock()
    
    private var linkingAccountIDs = Set<Int64>()
    
    internal init(database: Database, service: APIService, aggregation: Aggregation) {
        self.database = database
        self.service = service
        self.aggregation = aggregation
    }
    
    /**
     Creates/ Orders a new card on the host.
     - Parameters:
     - accountID: ID of the account to which the card is to be linked
     - firstName: First name of the card holder
     - middleName: Middle name of the card holder; Optional
     - lastName: Last name of the card holder
     - unitNumber: The address ID to which the card is to be sent;
     - completion: Optional completion handler with optional error if the request fails
     */
    public func createCard(accountID: Int64, firstName: String, middleName: String? = nil, lastName: String, addressID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APICreateCardRequest(accountID: accountID, firstName: firstName, middleName: middleName, lastName: lastName, addressID: addressID)
        
        service.createCard(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkCardsToAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Fetch cards from the cache
     - Parameters:
     - context: Managed object context to fetch these from; background or main thread
     - predicate: Predicate of properties to match for fetching. See `Card` for properties (Optional)
     - sortDescriptors: Array of sort descriptors to sort the results by. Defaults to cardID ascending (Optional)
     - limit: Fetch limit to set maximum number of returned items (Optional)
     - Returns: Array of cards See `Card` for properties
     */
    public func cards(context: NSManagedObjectContext,
                      filteredBy predicate: NSPredicate? = nil,
                      sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Card.cardID), ascending: true)],
                      limit: Int? = nil) -> [Card]? {
        
        return cachedObjects(type: Card.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch card by ID from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - cardID: Unique card ID to fetch
     - Returns: Card with matching cardID
     */
    public func card(context: NSManagedObjectContext, cardID: Int64) -> Card? {
        return cachedObject(type: Card.self, context: context, objectID: cardID, objectKey: #keyPath(Card.cardID))
    }
    
    /**
     Refresh cards from the host.
     
     - parameters:
     - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshCards(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchCards { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardsResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkCardsToAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific card by ID from the host
     
     - Parameters:
     - cardID: ID of the card to fetch
     - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshCard(cardID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchCard(cardID: cardID) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    self.linkCardsToAccounts(managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a card on the host
     
     - Parameters:
     - cardID: ID of the card to be updated
     - status:  Status of the card to be updated
     - nickName:  Nickname of the card to be updated
     - completion: Optional completion handler with optional error if the request fails
     */
    public func updateCard(cardID: Int64, status: Card.CardStatus? = nil, nickName: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APIUpdateCardRequest(status: status, nickName: nickName)
        
        service.updateCard(cardID: cardID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Get Public key for encrypting card PIN on the host
     
     - Parameter completion: Completion handler with `APICardPublicKeyResponse` result if succeeds and error if the request fails
     */
    public func getPublicKey(completion: @escaping (Result<APICardPublicKeyResponse, Error>) -> Void) {
        
        service.getPublicKey { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let response):
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
            }
        }
    }
    
    /**
     Activate a card on the host
     
     - Parameters:
     - cardID: ID of the card to be activated
     - panLastFourDigits:  Last for digits of the PAN on the physical card
     - completion: Optional completion handler with optional error if the request fails
     */
    public func activateCard(cardID: Int64, panLastFourDigits: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APIActivateCardRequest(panLastDigits: panLastFourDigits)
        
        service.activateCard(cardID: cardID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Set PIN for a card on the host
     
     - Parameters:
     - cardID: ID of the card for which the PIN needs to be set
     - encryptedPIN: Encrypted PIN using key from getPublicKey API
     - keyID: KeyID retuned from the getPublicKey API
     - completion: Optional completion handler with optional error if the request fails
     */
    public func setCardPin(cardID: Int64, encryptedPIN: String, keyID: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APICardSetPINRequest(keyID: keyID, cardPIN: encryptedPIN)
        
        service.setCardPIN(cardID: cardID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Lock a card on the host
     
     - Parameters:
     - cardID: ID of the card to be locked
     - reason: Reason for locking the card; Optional
     - completion: Optional completion handler with optional error if the request fails
     */
    public func lockCard(cardID: Int64, reason: APICardLockOrReplaceRequest.CardLockOrReplaceReason? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APICardLockOrReplaceRequest(reason: reason)
        
        service.lockCard(cardID: cardID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Unlock a card on the host
     
     - Parameters:
     - cardID: ID of the card to be unlocked
     - completion: Optional completion handler with optional error if the request fails
     */
    public func unlockCard(cardID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        
        service.unlockCard(cardID: cardID) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleCardResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Replace a card on the host
     
     - Parameters:
     - cardID: ID of the card to be locked
     - reason: Reason for locking the card; Optional
     - completion: Optional completion handler with optional error if the request fails
     */
    public func replaceCard(cardID: Int64, reason: APICardLockOrReplaceRequest.CardLockOrReplaceReason? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APICardLockOrReplaceRequest(reason: reason)
        
        service.replaceCard(cardID: cardID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.refreshCards { _ in
                        DispatchQueue.main.async {
                            completion?(.success)
                        }
                    }
            }
        }
    }
    
    // MARK: - Linking Objects
    
    private func linkCardsToAccounts(managedObjectContext: NSManagedObjectContext) {
        cardsLock.lock()
        aggregation.accountLock.lock()
        
        defer {
            cardsLock.unlock()
            aggregation.accountLock.unlock()
        }
        
        linkObjectToParentObject(type: Card.self, parentType: Account.self, managedObjectContext: managedObjectContext, linkedIDs: linkingAccountIDs, linkedKey: \Card.accountID, linkedKeyName: #keyPath(Card.accountID))
        
        linkingAccountIDs = Set()
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleCardsResponse(_ cardsResponse: [APICardResponse], managedObjectContext: NSManagedObjectContext) {
        cardsLock.lock()
        
        defer {
            cardsLock.unlock()
        }
        
        let updatedLinkedIDs = updateObjectsWithResponse(type: Card.self, objectsResponse: cardsResponse, primaryKey: #keyPath(Card.cardID), linkedKeys: [\Card.accountID], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        if let accountIDs = updatedLinkedIDs[\Card.accountID] {
            linkingAccountIDs = linkingAccountIDs.union(accountIDs)
        }
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
    private func handleCardResponse(_ cardResponse: APICardResponse, managedObjectContext: NSManagedObjectContext) {
        cardsLock.lock()
        
        defer {
            cardsLock.unlock()
        }
        
        updateObjectWithResponse(type: Card.self, objectResponse: cardResponse, primaryKey: #keyPath(Card.cardID), managedObjectContext: managedObjectContext)
        
        linkingAccountIDs.insert(cardResponse.accountID)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
}
