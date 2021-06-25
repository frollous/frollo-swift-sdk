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
     Fetch adresses from the cache
     - Parameters:
     - context: Managed object context to fetch these from; background or main thread
     - predicate: Predicate of properties to match for fetching. See `Address` for properties (Optional)
     - sortDescriptors: Array of sort descriptors to sort the results by. Defaults to addressID ascending (Optional)
     - limit: Fetch limit to set maximum number of returned items (Optional)
     - Returns: Array of cards See `Address` for properties
     */
    public func addresses(context: NSManagedObjectContext,
                          filteredBy predicate: NSPredicate? = nil,
                          sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Address.addressID), ascending: true)],
                          limit: Int? = nil) -> [Address]? {
        
        return cachedObjects(type: Address.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetch address by ID from the cache
     
     - parameters:
     - context: Managed object context to fetch these from; background or main thread
     - addressID: Unique address ID to fetch
     - Returns: Address with matching addressID
     */
    public func address(context: NSManagedObjectContext, addressID: Int64) -> Address? {
        return cachedObject(type: Address.self, context: context, objectID: addressID, objectKey: #keyPath(Address.addressID))
    }
    
    /**
     Refresh addresses from the host.
     
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
    
    /**
     Create an address in the host
     
     - Parameters:
     - unitNumber: unit number of the Address. (Optional)
     - buildingName: building name of the Address. (Optional)
     - streetNumber: building number of the Address. (Optional)
     - streetName: street name of the Address. (Optional)
     - streetType: street type of the Address. (Optional)
     - suburb: name of suburb of the Address. (Optional)
     - town: name of town of the Address. (Optional)
     - region: region of the Address. (Optional)
     - state: state of the Address. (Optional)
     - country: country name in short form of the Address. eg: AUD
     - postcode: postcode of the Address. (Optional)
     - completion: Optional completion handler with optional error if the request fails & ID of address if request succeeds
     */
    public func createAddress(unitNumber: String?, buildingName: String?, streetNumber: String?, streetName: String?, streetType: String?, suburb: String?, town: String?, region: String?, state: String?, country: String, postcode: String, completion: FrolloSDKObjectCompletionHandler? = nil) {
        
        let request = APIPostAddressRequest(buildingName: buildingName, unitNumber: unitNumber, streetNumber: streetNumber, streetName: streetName, streetType: streetType, suburb: suburb, town: town, region: region, state: state, country: country, postcode: postcode)
        
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
                        completion?(.success(response.id))
                    }
            }
        }
    }
    
    /**
     Update an Address on the host.
     
     - Parameters:
     - addressID: The ID of the address to be updated
     - unitNumber: unit number of the Address. (Optional)
     - buildingName: building name of the Address. (Optional)
     - streetNumber: building number of the Address. (Optional)
     - streetName: street name of the Address. (Optional)
     - streetType: street type of the Address. (Optional)
     - suburb: name of suburb of the Address. (Optional)
     - town: name of town of the Address. (Optional)
     - region: region of the Address. (Optional)
     - state: state of the Address. (Optional)
     - country: country name in short form of the Address. eg: AUD
     - postcode: postcode of the Address. (Optional)
     - completion: Optional completion handler with optional error if the request fails
     */
    public func updateAddress(addressID: Int64, unitNumber: String?, buildingName: String?, streetNumber: String?, streetName: String?, streetType: String?, suburb: String?, town: String?, region: String?, state: String?, country: String, postcode: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let request = APIPostAddressRequest(buildingName: buildingName, unitNumber: unitNumber, streetNumber: streetNumber, streetName: streetName, streetType: streetType, suburb: suburb, town: town, region: region, state: state, country: country, postcode: postcode)
        
        service.updateAddress(addressID: addressID, request: request) { result in
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
     Delete a specific address by ID from the host
     
     - parameters:
        - contactID: ID of the address to be deleted
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteAddress(addressID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        
        service.deleteAddress(addressID: addressID) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedAddress(addressID: addressID)
                    
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
    public func fetchAddress(for addressID: String, completion: @escaping (Result<APIAddressAutocompleteResopnse, Error>) -> Void) {
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
    
    private func removeCachedAddress(addressID: Int64) {
        addressLock.lock()
        
        defer {
            addressLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: Address.self, id: addressID, primaryKey: #keyPath(Address.addressID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
}
