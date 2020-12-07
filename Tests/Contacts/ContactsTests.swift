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
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class ContactsTests: BaseTestCase {
    
    var service: APIService!
    var contacts: Contacts!
    
    override func setUp() {
        testsKeychainService = "ContactsTests"
        super.setUp()
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }


    func testRefreshContacts() {
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        contacts = Contacts(database: database, service: service)
        
        let expectation1 = expectation(description: "Network Request")
        let expectation2 = expectation(description: "Core Data Update")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ContactsEndpoint.contacts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_contacts", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        contacts = Contacts(database: database, service: service)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let contact = Contact(context: managedObjectContext)
                contact.populateTestData()
                contact.contactID = 10
                contact.name = "Overridden Name"
                
                try? managedObjectContext.save()
            }
            
            self.contacts.refreshContacts(size: 5) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let (before, after, total)):
                        XCTAssertEqual(before, nil)
                        XCTAssertEqual(after, "10")
                        XCTAssertEqual(total, 10)
                }
                
                expectation1.fulfill()
            }
            
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
            
            do {
                
                let fetchedContacts = try context.fetch(fetchRequest)
                let updatedContact = self.contacts.contact(context: context, contactID: 10)
                XCTAssertEqual(updatedContact?.name, "Sincy Chacko")
                
                XCTAssertEqual(fetchedContacts.count, 10)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
    }
    
    func testFetchPaginatedContacts() {
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        let expectation1 = expectation(description: "Database")
        let expectation2 = expectation(description: "Network Request Page 1")
        let expectation3 = expectation(description: "Fetch Request Page 1")
        let expectation4 = expectation(description: "Network Request Page 2")
        let expectation5 = expectation(description: "Fetch Request Page 2")
        
        let contactsStub = connect(endpoint: ContactsEndpoint.contacts.path.prefixedWithSlash, toResourceWithName: "get_contacts")
        
        contacts = Contacts(database: database, service: service)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let contact = Contact(context: managedObjectContext)
                contact.populateTestData()
                contact.contactID = 10
                contact.name = "Overridden Name"
                
                try? managedObjectContext.save()
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        contacts.refreshContacts(size: 10) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let (before, after, total)):
                    XCTAssertEqual(before, nil)
                    XCTAssertEqual(after, "10")
                    XCTAssertEqual(total, 10)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
            
            do {
                let fetchedContacts = try context.fetch(fetchRequest)
                let updatedContact = self.contacts.contact(context: context, contactID: 10)
                XCTAssertEqual(updatedContact?.name, "Sincy Chacko")
                
                XCTAssertEqual(fetchedContacts.count, 10)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        OHHTTPStubs.removeStub(contactsStub)
        
        connect(endpoint: ContactsEndpoint.contacts.path.prefixedWithSlash, toResourceWithName: "get_contacts_page_2")
        
        self.contacts.refreshContacts(after: "10", size: 10) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let (before, after, total)):
                    XCTAssertEqual(before, "10")
                    XCTAssertEqual(after, nil)
                    XCTAssertEqual(total, 13)
            }
            
            expectation4.fulfill()
        }
        
        wait(for: [expectation4], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = database.viewContext
            
            let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
            
            do {
                let fetchedContacts = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedContacts.count, 13)
                XCTAssertNotNil(self.contacts.contact(context: context, contactID: 10))
                
            } catch {
                XCTFail(error.localizedDescription)
            }
                        
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 3.0)
        
    }

    func testCreateBPAYContact() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ContactsEndpoint.contacts.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_bpay_contact", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        contacts = Contacts(database: database, service: service)

        database.setup { [self] (error) in
            XCTAssertNil(error)

            self.contacts.createBPAYContact(nickName: "ACME Inc.", billerCode: "209999", crn: "84100064513925", billerName: "ACME Inc.") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }

    func testCreatePayAnyoneContact() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ContactsEndpoint.contacts.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_payAnyone_contact", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        contacts = Contacts(database: database, service: service)

        database.setup { [self] (error) in
            XCTAssertNil(error)

            self.contacts.createPayAnyoneContact(name: "Johnathan", nickName: "Johnny Boy", accountName: "Mr Johnathan Smith", bsb: "100-123", accountNumber: "12345678") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }

    func testCreatePayIDContact() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ContactsEndpoint.contacts.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_payID_contact", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        contacts = Contacts(database: database, service: service)

        self.contacts.createPayIDContact(name: "Johnathan", nickName: "Johnny Boy", description: "That guy I buy tyres from", payID: "0412345678", payIDName: "J SMITH", payIDType: .phoneNumber) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }

    func testCreateInternationalContact() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ContactsEndpoint.contacts.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_international_contact", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())

        contacts = Contacts(database: database, service: service)

        database.setup { [self] (error) in
            XCTAssertNil(error)

            self.contacts.createInternationalContact(name: "Anne Frank", nickName: "Annie", country: "New Zeland", bankCountry: "New Zeland", accountNumber: "12345678") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        OHHTTPStubs.removeAllStubs()
    }

}
