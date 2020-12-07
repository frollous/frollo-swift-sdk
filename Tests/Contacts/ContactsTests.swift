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


    func testRefreshContacts(){
        
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
                contact.contactID = 11
                contact.name = "Overridden Name"
                
                try? managedObjectContext.save()
            }
            
            self.contacts.refreshContacts(size: 5) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let (before, after, total)):
                        XCTAssertEqual(before, nil)
                        XCTAssertEqual(after, nil)
                        XCTAssertEqual(total, 11)
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
                let updatedContact = self.contacts.contact(context: context, contactID: 11)
                XCTAssertEqual(updatedContact?.name, "John Cena")
                
                XCTAssertEqual(fetchedContacts.count, 11)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
    }

}
