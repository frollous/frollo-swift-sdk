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
    
    // Notification fired when contacts cache has been updated
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
     Fetch merchants from the cache
     
     - parameters:
        - context: Managed object context to fetch these from; background or main thread
        - type: Filter contacts by the type (Optional)
        - filteredBy: Predicate of properties to match for fetching. See `Contact` for properties (Optional)
        - sortedBy: Array of sort descriptors to sort the results by. Defaults to merchantID ascending (Optional)
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
     Refresh all contacts from the host.
     
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
                    Log.error(error.localizedDescription)
                    
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
    
    public func createPayAnyoneContact(name: String? = nil, nickName: String, description: String? = nil, accountName: String, bsb: String, accountNumber: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayAnyone = .init(accountHolder: accountName, bsb: bsb, accountNumber: accountNumber)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .payAnyone, details: .payAnyone(paymentDetails))
        
        service.createContact(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
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
    
    public func createBPAYContact(name: String? = nil, nickName: String, description: String? = nil, billerCode: String, crn: String, billerName: String, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.Biller = .init(billerCode: billerCode, crn: crn, billerName: billerName)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .BPAY, details: .BPAY(paymentDetails))
        
        service.createContact(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
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
    
    public func createPayIDContact(name: String? = nil, nickName: String, description: String? = nil, payID: String, payIDName: String, payIDType: PayIDContact.PayIDType, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: PaymentDetails.PayID = .init(payid: payID, name: payIDName, idType: payIDType)
        let request = APICreateContactRequest(name: name ?? nickName, nickName: nickName, description: description, type: .payID, details: .payID(paymentDetails))
        
        service.createContact(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
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
    
    public func createInternationalContact(name: String? = nil, nickName: String, description: String? = nil, country: String, message: String? = nil, bankCountry: String, accountNumber: String, bankAddress: String? = nil, bic: String? = nil, fedwireNumber: String? = nil, sortCode: String? = nil, chipNumber: String? = nil, routingNumber: String? = nil, legalEntityNumber: String? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        
        let paymentDetails: APICreateInternationalContactRequest.InternationalPaymentDetails = .init(name: name, country: country, message: message, bankcountry: bankCountry, accountNumber: accountNumber, bankAddress: bankAddress, bic: bic, fedwireNumber: fedwireNumber, sortCode: sortCode, chipNumber: chipNumber, routingNumber: routingNumber, legalEntityIdentifier: legalEntityNumber)
        let request = APICreateInternationalContactRequest(name: name, nickName: nickName, description: description, paymentDetails: paymentDetails)
        
        service.createInternationalContact(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
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
        
        updateObjectsWithResponse(type: Contact.self, objectsResponse: contactsResponse, primaryKey: #keyPath(Contact.contactID), linkedKeys: [], filterPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), managedObjectContext: managedObjectContext)
        
        managedObjectContext.performAndWait {
            do {
                try managedObjectContext.save()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
}
