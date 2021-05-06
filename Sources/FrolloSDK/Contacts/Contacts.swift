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

typealias PaymentDetails = APIContactResponse.ContactDetailsType

/// Manages all aspects of Contacts
public class Contacts: CachedObjects, ResponseHandler {
    
    private let service: APIService
    private let database: Database
    
    /// Notification fired when contacts cache has been updated
    public static let contactsUpdatedNotification = Notification.Name("FrolloSDK.contacts.contactsUpdatedNotification")
    
    private let contactsLock = NSLock()
    
    internal init(database: Database, service: APIService) {
        self.database = database
        self.service = service
    }
    
    /**
     Fetch contact by ID from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - contactID: Unique contact ID to fetch
     */
    public func contact(context: NSManagedObjectContext, contactID: Int64) -> Contact? {
        return cachedObject(type: Contact.self, context: context, objectID: contactID, objectKey: #keyPath(Contact.contactID))
    }
    
    /**
     Fetch contacts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - type: Filter contacts by the type (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Contact` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to contactID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func contacts(context: NSManagedObjectContext,
                         type: Contact.ContactType? = nil,
                         filteredBy predicate: NSPredicate? = nil,
                         sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Contact.contactID), ascending: true)],
                         limit: Int? = nil) -> [Contact]? {
        var predicates = [NSPredicate]()
        
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(Contact.contactTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return cachedObjects(type: Contact.self, context: context, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Fetched results controller of contacts from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - type: Filter contacts by the type (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Contact` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to contactID ascending (Optional)
        - limit: Fetch limit to set maximum number of returned items (Optional)
     */
    public func contactsFetchedResultsController(context: NSManagedObjectContext,
                                                 type: Contact.ContactType? = nil,
                                                 filteredBy predicate: NSPredicate? = nil,
                                                 sortedBy sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: #keyPath(Contact.contactID), ascending: true)],
                                                 limit: Int? = nil) -> NSFetchedResultsController<Contact>? {
        var predicates = [NSPredicate]()
        
        if let filterType = type {
            predicates.append(NSPredicate(format: #keyPath(Contact.contactTypeRawValue) + " == %@", argumentArray: [filterType.rawValue]))
        }
        
        if let filterPredicate = predicate {
            predicates.append(filterPredicate)
        }
        
        return fetchedResultsController(type: Contact.self, context: context, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
    }
    
    /**
     Refresh a specific contact by ID from the host
     
     - parameters:
        - contactID: ID of the contact to fetch
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshContact(contactID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        
        service.fetchContact(contactID: contactID) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleContactResponse(response, managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Contacts.contactsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Refresh contacts from the host.
     
     - parameters:
        - before: Contact ID to fetch before this contact (optional)
        - after: Contact ID to fetch upto this contact (optional)
        - size: Batch size of contact to returned by API (optional); defaults to 500
        - completion: Optional completion handler with optional error if the request fails
     */
    public func refreshContacts(before: String? = nil, after: String? = nil, size: Int? = 500, completion: FrolloSDKPaginatedCompletionHandler? = nil) {
        
        service.fetchContacts(before: before, after: after, size: size) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleContactsResponse(response.data.elements, before: response.paging?.cursors?.before, after: response.paging?.cursors?.after, managedObjectContext: managedObjectContext)
                    
                    NotificationCenter.default.post(name: Contacts.contactsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success(PaginationInfo(response.paging?.cursors?.before, response.paging?.cursors?.after, response.paging?.total)))
                    }
            }
        }
    }
    
    /**
     Create a Pay Anyone contact on the host.
     
     - Parameters:
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - accountName:  Account name of the payAnyone contact
     - bsb:  BSB of the payAnyone contact
     - accountNumber:  Account number of the payAnyone contact
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func createPayAnyoneContact(name: String? = nil, nickName: String, description: String? = nil, accountName: String, bsb: String, accountNumber: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayAnyone = .init(accountHolder: accountName, bsb: bsb, accountNumber: accountNumber)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .payAnyone, details: .payAnyone(paymentDetails))
        
        service.createContact(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Create a BPAY contact on the host.
     
     - Parameters:
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - billerCode:  Biller Code of the BPAY contact
     - crn:  CRN of the BPAY contact
     - billerName:  Biller Namee of the BPAY contact
     - crnType:  `CRNType` Type of the Biller's CRN; defaulted to fixed crn.
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func createBPAYContact(name: String? = nil, nickName: String, description: String? = nil, billerCode: String, crn: String, billerName: String, crnType: BPAYContact.CRNType = .fixed, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.Biller = .init(billerCode: billerCode, crn: crn, billerName: billerName, crnType: crnType)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .BPAY, details: .BPAY(paymentDetails))
        
        service.createContact(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Create a PayID contact on the host.
     
     - Parameters:
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - payID:  PayID value of the contact
     - payIDName:  Name of the PayID contact
     - payIDType:  Type of PayID; e.g. phone, email, abn, organisation id
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func createPayIDContact(name: String? = nil, nickName: String, description: String? = nil, payID: String, payIDName: String, payIDType: PayIDContact.PayIDType, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayID = .init(payid: payID, name: payIDName, type: payIDType)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .payID, details: .payID(paymentDetails))
        
        service.createContact(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Create a International contact on the host.
     
     - Parameters:
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - country:  Country of the contact
     - message:  Message of the contact
     - bankCountry:  Country of the contact's bank
     - accountNumber:  Account number of the contact
     - bankAddress:  Bank Address of the contact
     - bic:  BIC of the contact's bank
     - fedwireNumber: Fedwire number of the contact's bank
     - sortCode:  Sort code of the contact's bank
     - chipNumber:  Chip number of the contact's bank
     - routingNumber:  Routing number of the contact's bank
     - legalEntityNumber:  Legal entity identifier of the contact's bank
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func createInternationalContact(name: String? = nil, nickName: String, description: String? = nil, country: String, message: String? = nil, bankCountry: String, accountNumber: String, bankAddress: String? = nil, bic: String? = nil, fedwireNumber: String? = nil, sortCode: String? = nil, chipNumber: String? = nil, routingNumber: String? = nil, legalEntityNumber: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: APICreateInternationalContactRequest.InternationalPaymentDetails = .init(name: name, country: country, message: message, bankcountry: bankCountry, accountNumber: accountNumber, bankAddress: bankAddress, bic: bic, fedwireNumber: fedwireNumber, sortCode: sortCode, chipNumber: chipNumber, routingNumber: routingNumber, legalEntityIdentifier: legalEntityNumber)
        let request = APICreateInternationalContactRequest(name: name, nickName: nickName, description: description, paymentDetails: paymentDetails)
        
        service.createInternationalContact(request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a Pay Anyone contact on the host.
     
     - Parameters:
     - contactID: The ID of the contact to be updated
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - accountName:  Account name of the payAnyone contact
     - bsb:  BSB of the payAnyone contact
     - accountNumber:  Account number of the payAnyone contact
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func updatePayAnyoneContact(contactID: Int64, name: String? = nil, nickName: String, description: String? = nil, accountName: String, bsb: String, accountNumber: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayAnyone = .init(accountHolder: accountName, bsb: bsb, accountNumber: accountNumber)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .payAnyone, details: .payAnyone(paymentDetails))
        
        service.updateContact(contactID: contactID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleContactResponse(response, managedObjectContext: managedObjectContext)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a BPAY contact on the host.
     
      - Parameters:
      - contactID: The ID of the contact to be updated
      - name: Name of the contact; default value will be nickName (Optional)
      - nickName:  Nickname of the contact
      - description: Description of the contact (Optional)
      - billerCode:  Biller Code of the BPAY contact
      - crn:  CRN of the BPAY contact
      - billerName:  Biller Namee of the BPAY contact
      - crnType:  `CRNType` Type of the Biller's CRN; defaulted to fixed crn.
      - completion:  Optional completion handler with optional error if the request fails
     */
    public func updateBPAYContact(contactID: Int64, name: String? = nil, nickName: String, description: String? = nil, billerCode: String, crn: String, billerName: String, crnType: BPAYContact.CRNType = .fixed, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.Biller = .init(billerCode: billerCode, crn: crn, billerName: billerName, crnType: crnType)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .BPAY, details: .BPAY(paymentDetails))
        
        service.updateContact(contactID: contactID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleContactResponse(response, managedObjectContext: managedObjectContext)
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a PayID contact on the host.
     
     - Parameters:
     - contactID: The ID of the contact to be updated
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - payID:  PayID value of the contact
     - payIDName:  Name of the PayID contact
     - payIDType:  Type of PayID; e.g. phone, email, abn, organisation id
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func updatePayIDContact(contactID: Int64, name: String? = nil, nickName: String, description: String? = nil, payID: String, payIDName: String, payIDType: PayIDContact.PayIDType, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayID = .init(payid: payID, name: payIDName, type: payIDType)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .payID, details: .payID(paymentDetails))
        
        service.updateContact(contactID: contactID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleContactResponse(response, managedObjectContext: managedObjectContext)
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Update a PayID contact on the host.
     
     - Parameters:
     - contactID: The ID of the contact to be updated
     - name: Name of the contact; default value will be nickName (Optional)
     - nickName:  Nickname of the contact
     - description: Description of the contact (Optional)
     - country:  Country of the contact
     - message:  Message of the contact
     - bankCountry:  Country of the contact's bank
     - accountNumber:  Account number of the contact
     - bankAddress:  Bank Address of the contact
     - bic:  BIC of the contact's bank
     - fedwireNumber: Fedwire number of the contact's bank
     - sortCode:  Sort code of the contact's bank
     - chipNumber:  Chip number of the contact's bank
     - routingNumber:  Routing number of the contact's bank
     - legalEntityNumber:  Legal entity identifier of the contact's bank
     - completion:  Optional completion handler with optional error if the request fails
     */
    public func updateInternationalContact(contactID: Int64, name: String? = nil, nickName: String, description: String? = nil, country: String, message: String? = nil, bankCountry: String, accountNumber: String, bankAddress: String? = nil, bic: String? = nil, fedwireNumber: String? = nil, sortCode: String? = nil, chipNumber: String? = nil, routingNumber: String? = nil, legalEntityNumber: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: APICreateInternationalContactRequest.InternationalPaymentDetails = .init(name: name, country: country, message: message, bankcountry: bankCountry, accountNumber: accountNumber, bankAddress: bankAddress, bic: bic, fedwireNumber: fedwireNumber, sortCode: sortCode, chipNumber: chipNumber, routingNumber: routingNumber, legalEntityIdentifier: legalEntityNumber)
        let request = APICreateInternationalContactRequest(name: name, nickName: nickName, description: description, paymentDetails: paymentDetails)
        
        service.updateInternationalContact(contactID: contactID, request: request) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success(let response):
                    let managedObjectContext = self.database.newBackgroundContext()
                    
                    self.handleContactResponse(response, managedObjectContext: managedObjectContext)
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Delete a specific contact by ID from the host
     
     - parameters:
        - contactID: ID of the contact to be deleted
        - completion: Optional completion handler with optional error if the request fails
     */
    public func deleteContact(contactID: Int64, completion: FrolloSDKCompletionHandler? = nil) {
        service.deleteContact(contactID: contactID) { result in
            switch result {
                case .failure(let error):
                    error.logError()
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    self.removeCachedContact(contactID: contactID)
                    NotificationCenter.default.post(name: Contacts.contactsUpdatedNotification, object: self)
                    
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleContactsResponse(_ contactsResponse: [APIContactResponse], before: String?, after: String?, managedObjectContext: NSManagedObjectContext) {
        
        contactsLock.lock()
        
        defer {
            contactsLock.unlock()
        }
        
        var predicates = [NSPredicate]()
        
        if let beforeID = Int64(before ?? "") {
            predicates.append(NSPredicate(format: #keyPath(Contact.contactID) + " > %ld", argumentArray: [beforeID]))
        }
        
        if let afterID = Int64(after ?? "") {
            predicates.append(NSPredicate(format: #keyPath(Contact.contactID) + " <= %ld", argumentArray: [afterID]))
        }
        
        updateContactsObjectsWithResponse(contactsResponse, filterPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
    private func updateContactsObjectsWithResponse(_ contactsResponse: [APIContactResponse], filterPredicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) {
        // Sort by ID
        let sortedObjectResponses = contactsResponse.sorted { $0.id < $1.id }
        
        // Build id list predicate
        let objectIDs = sortedObjectResponses.map { $0.id }
        
        managedObjectContext.performAndWait {
            // Fetch existing providers for updating
            let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
            
            var predicates = [NSPredicate(format: #keyPath(Contact.contactID) + " IN %@", argumentArray: [objectIDs])]
            
            if let filter = filterPredicate {
                predicates.append(filter)
            }
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Contact.contactID), ascending: true)]
            
            do {
                let existingObjects = try managedObjectContext.fetch(fetchRequest)
                
                var index = 0
                
                for objectResponse in sortedObjectResponses {
                    var object: Contact
                    
                    if index < existingObjects.count, existingObjects[index].contactID == objectResponse.id {
                        object = existingObjects[index]
                        index += 1
                    } else {
                        switch objectResponse.contactType {
                            case .payAnyone:
                                object = PayAnyoneContact(context: managedObjectContext)
                            case .BPAY:
                                object = BPAYContact(context: managedObjectContext)
                            case .payID:
                                object = PayIDContact(context: managedObjectContext)
                            case .international:
                                object = InternationalContact(context: managedObjectContext)
                        }
                    }
                    
                    object.update(response: objectResponse, context: managedObjectContext)
                }
                
                // Fetch and delete any leftovers
                let deleteRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
                
                var deletePredicates = [NSPredicate(format: "NOT " + #keyPath(Contact.contactID) + " IN %@", argumentArray: [objectIDs])]
                
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
    
    private func handleContactResponse(_ contactResponse: APIContactResponse, managedObjectContext: NSManagedObjectContext) {
        
        contactsLock.lock()
        
        defer {
            contactsLock.unlock()
        }
        
        let type: Contact.Type
        switch contactResponse.contactType {
            case .payAnyone:
                type = PayAnyoneContact.self
            case .payID:
                type = PayIDContact.self
            case .BPAY:
                type = BPAYContact.self
            case .international:
                type = InternationalContact.self
        }
        
        updateObjectWithResponse(type: type, objectResponse: contactResponse, primaryKey: #keyPath(Contact.contactID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
    private func removeCachedContact(contactID: Int64) {
        contactsLock.lock()
        
        defer {
            contactsLock.unlock()
        }
        
        let managedObjectContext = database.newBackgroundContext()
        
        removeObject(type: Contact.self, id: contactID, primaryKey: #keyPath(Contact.contactID), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                error.logError()
            }
        }
    }
    
}
