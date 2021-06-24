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

/**
 Address Management
 
 Manages all the addresses on the User
 */
public class AddressManagement: CachedObjects, ResponseHandler {
    
    private let database: Database
    private let service: APIService
    
    private let addressLock = NSLock()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    /**
     Fetch all the addresses on the user
     
     - parameters:
     - completion: Completion handler with any error that occurred
     */
    /**
     Fetch cards from the cache
     - Parameters:
     - context: Managed object context to fetch these from; background or main thread
     - predicate: Predicate of properties to match for fetching. See `Card` for properties (Optional)
     - sortDescriptors: Array of sort descriptors to sort the results by. Defaults to cardID ascending (Optional)
     - limit: Fetch limit to set maximum number of returned items (Optional)
     - Returns: Array of cards See `Card` for properties
     */
    public func addresses(context: NSManagedObjectContext,
                          filteredBy predicate: NSPredicate? = nil,
                          sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Address.addressID), ascending: true)],
                          limit: Int? = nil) -> [Address]? {
        
        return cachedObjects(type: Address.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch card by ID from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - cardID: Unique card ID to fetch
     - Returns: Card with matching cardID
     */
    public func address(context: NSManagedObjectContext, addressID: Int64) -> Address? {
        return cachedObject(type: Address.self, context: context, objectID: addressID, objectKey: #keyPath(Address.addressID))
    }
    
    /**
     Refresh cards from the host.
     
     - parameters:
     - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshAddresses(completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchAddresses { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAddressesResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh a specific address by ID from the host
     
     - Parameters:
     - addressID: ID of the address to fetch
     - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshAddress(addressID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.fetchAddress(addressID: addressID) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAddressResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    public func createAddress(unitNumber: String?, buildingName: String?, streetNumber: String?, streetName: String?, streetType: String?, suburb: String, region: String, state: String, country: String, postcode: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APIPostAddressRequest(buildingName: buildingName, unitNumber: unitNumber, streetNumber: streetNumber, streetName: streetName, streetType: streetType, suburb: suburb, region: region, state: state, country: country, postcode: postcode)
        
        service.createAddress(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleAddressResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    
    /**
     Get addresses list that matches the query string
     
     - Parameters:
     - query: String to match address
     - max: Maximum number of items to fetch. Should be between 10 and 100; defaults to 20.
     - completion: Completion handler with either the `AddressAutocompleteResponse` list from the host or an error
     */
    public func addressAutocomplete(query: String, max: Int = 20, completion: @escaping (Result<[AddressAutocomplete], Error>) -> Void) {
        service.addressAutocomplete(query: query, max: max) { result in
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
     Get address by ID
     
     - Parameters:
     - addressID: ID of the address to get the details
     - completion: Completion handler with either the `Address` from the host or an error
     */
    public func getAddress(for addressID: String, completion: @escaping (Result<Address, Error>) -> Void) {
        service.getAddress(addressID: addressID) { result in
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
        
    
    // MARK: - Response Handling
    
    private func handleAddressesResponse(_ addressResponse: [APIAddressResponse], managedObjectContext: NSManagedObjectContext) {
        addressLock.lock()
        
        defer {
            addressLock.unlock()
        }
        
        updateObjectsWithResponse(type: Address.self, objectsResponse: addressResponse, primaryKey: #keyPath(Address.addressID), linkedKeys: [], filterPredicate: nil, managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
    private func handleAddressResponse(_ addressResponse: APIAddressResponse, managedObjectContext: NSManagedObjectContext) {
        addressLock.lock()
        
        defer {
            addressLock.unlock()
        }
        
        updateObjectWithResponse(type: Address.self, objectResponse: addressResponse, primaryKey: #keyPath(Address.addressID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
}
