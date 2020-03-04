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
@testable import FrolloSDK
import XCTest

import OHHTTPStubs

class AggregationTests: BaseTestCase {
    
    override func setUp() {
        testsKeychainService = "AggregationTests"
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    private func aggregation(loggedIn: Bool) -> Aggregation {
        return self.aggregation(keychain: self.defaultKeychain(isNetwork: true), loggedIn: loggedIn)
    }
    
    // MARK: - Provider Tests
    
    func testFetchProviderByID() {
        let expectation1 = expectation(description: "Completion")
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testProvider = Provider(context: managedObjectContext)
                testProvider.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let provider = aggregation.provider(context: self.context, providerID: id)
            
            XCTAssertNotNil(provider)
            XCTAssertEqual(provider?.providerID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviders() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testProvider1 = Provider(context: managedObjectContext)
                testProvider1.populateTestData()
                testProvider1.containerLoan = true
                
                let testProvider2 = Provider(context: managedObjectContext)
                testProvider2.populateTestData()
                testProvider2.containerLoan = false
                
                let testProvider3 = Provider(context: managedObjectContext)
                testProvider3.populateTestData()
                testProvider3.containerLoan = true
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "containerLoan == true", argumentArray: nil)
            let providers = aggregation.providers(context: self.context, filteredBy: predicate)
            
            XCTAssertNotNil(providers)
            XCTAssertEqual(providers?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testProvidersFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testProvider1 = Provider(context: managedObjectContext)
                testProvider1.populateTestData()
                testProvider1.containerLoan = true
                
                let testProvider2 = Provider(context: managedObjectContext)
                testProvider2.populateTestData()
                testProvider2.containerLoan = false
                
                let testProvider3 = Provider(context: managedObjectContext)
                testProvider3.populateTestData()
                testProvider3.containerLoan = true
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "containerLoan == true", argumentArray: nil)
            let fetchedResultsController = aggregation.providersFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshProvidersIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providersUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.providers.path.prefixedWithSlash, toResourceWithName: "providers_valid")
        
        database.setup { error in
            XCTAssertNil(error)
            
            let aggregation = self.aggregation(loggedIn: true)
            
            aggregation.refreshProviders { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                        
                        do {
                            let fetchedProviders = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviders.count, 50)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshProvidersFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providers.path.prefixedWithSlash, toResourceWithName: "providers_valid")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshProviders { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshProviderByIDIsCached() {
        let expectation1 = expectation(description: "Database")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")
        let expectation4 = expectation(description: "Network Request 2")
        let expectation5 = expectation(description: "Fetch Request 2")
        let notificationExpectation = expectation(forNotification: Aggregation.providersUpdatedNotification, object: nil, handler: nil)
        
        let providerStub = connect(endpoint: AggregationEndpoint.providers.path.prefixedWithSlash, toResourceWithName: "providers_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        
        aggregation.refreshProviders { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context
            
            let totalFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            
            do {
                let fetchedTotalProviders = try context.fetch(totalFetchRequest)
                
                XCTAssertEqual(fetchedTotalProviders.count, 50)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let individualFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            individualFetchRequest.predicate = NSPredicate(format: "providerID == %ld", argumentArray: [586])
            
            do {
                let fetchedIndividualProviders = try context.fetch(individualFetchRequest)
                
                XCTAssertEqual(fetchedIndividualProviders.count, 1)
                
                if let provider = fetchedIndividualProviders.first {
                    XCTAssertEqual(provider.providerID, 586)
                } else {
                    XCTFail("Provider not found")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        OHHTTPStubs.removeStub(providerStub)
        
        connect(endpoint: AggregationEndpoint.providers.path.prefixedWithSlash, toResourceWithName: "providers_updated")
        
        aggregation.refreshProviders { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation4.fulfill()
        }
        
        wait(for: [expectation4, notificationExpectation], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context
            
            let totalFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            
            do {
                let fetchedTotalProviders = try context.fetch(totalFetchRequest)
                
                XCTAssertEqual(fetchedTotalProviders.count, 50)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let individualFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            individualFetchRequest.predicate = NSPredicate(format: "providerID == %ld", argumentArray: [15441])
            
            do {
                let fetchedIndividualProviders = try context.fetch(individualFetchRequest)
                
                XCTAssertEqual(fetchedIndividualProviders.count, 0)
                XCTAssertNil(fetchedIndividualProviders.first)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 3.0)
        
    }
    
    func testRefreshProviderByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.provider(providerID: 12345).path.prefixedWithSlash, toResourceWithName: "provider_id_12345")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshProvider(providerID: 12345) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshProvidersUpdate() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providers.path.prefixedWithSlash, toResourceWithName: "providers_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshProviders { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
                        
                        do {
                            let fetchedProviders = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviders.count, 50)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    // MARK: - Provider Account Tests
    
    func testFetchProviderAccountByID() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testProviderAccount = ProviderAccount(context: managedObjectContext)
                testProviderAccount.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let providerAccount = aggregation.providerAccount(context: self.context, providerAccountID: id)
            
            XCTAssertNotNil(providerAccount)
            XCTAssertEqual(providerAccount?.providerAccountID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderAccounts() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testProviderAccount1 = ProviderAccount(context: managedObjectContext)
                testProviderAccount1.populateTestData()
                testProviderAccount1.providerID = 69
                
                let testProviderAccount2 = ProviderAccount(context: managedObjectContext)
                testProviderAccount2.populateTestData()
                testProviderAccount2.providerID = 12
                
                let testProviderAccount3 = ProviderAccount(context: managedObjectContext)
                testProviderAccount3.populateTestData()
                testProviderAccount3.providerID = 69
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "providerID == 69", argumentArray: nil)
            let providerAccounts = aggregation.providerAccounts(context: self.context, filteredBy: predicate, limit: 1)
            
            XCTAssertNotNil(providerAccounts)
            XCTAssertEqual(providerAccounts?.count, 1)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testProviderAccountsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testProviderAccount1 = ProviderAccount(context: managedObjectContext)
                testProviderAccount1.populateTestData()
                testProviderAccount1.providerID = 69
                
                let testProviderAccount2 = ProviderAccount(context: managedObjectContext)
                testProviderAccount2.populateTestData()
                testProviderAccount2.providerID = 12
                
                let testProviderAccount3 = ProviderAccount(context: managedObjectContext)
                testProviderAccount3.populateTestData()
                testProviderAccount3.providerID = 69
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "providerID == 69", argumentArray: nil)
            let fetchedResultsController = aggregation.providerAccountsFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshProviderAccountsIsCached() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshProviderAccounts { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 4)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        aggregation.refreshProviderAccounts { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 4, "Provider Accounts Duplicated")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshProviderAccountsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshProviderAccounts { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshProviderAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.providerAccount(providerAccountID: 123).path.prefixedWithSlash, toResourceWithName: "provider_account_id_123")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshProviderAccount(providerAccountID: 123) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "providerAccountID == %ld", argumentArray: [123])
                        
                        do {
                            let fetchedProviderAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviderAccounts.first?.providerAccountID, 123)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshProviderAccountByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccount(providerAccountID: 123).path.prefixedWithSlash, toResourceWithName: "provider_account_id_123")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshAccount(accountID: 123) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testProviderAccountsLinkToProviders() {
        let expectation1 = expectation(description: "Network Provider Request")
        let expectation2 = expectation(description: "Network Provider Account Request")
        
        connect(endpoint: AggregationEndpoint.provider(providerID: 12345).path.prefixedWithSlash, toResourceWithName: "provider_id_12345")
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshProviderAccounts { result in
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "providerAccountID == %ld", argumentArray: [867])
            
            do {
                let fetchedProviderAccounts = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedProviderAccounts.count, 1)
                
                if let providerAccount = fetchedProviderAccounts.first {
                    XCTAssertNotNil(providerAccount.provider)
                    
                    XCTAssertEqual(providerAccount.providerID, providerAccount.provider?.providerID)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
    }
    
    func testCreateProviderAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountsUpdatedNotification, object: nil, handler: nil)
        let providerID: Int64 = 12345
        
        let loginForm = ProviderLoginForm.loginFormFilledData()
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_account_id_123", addingStatusCode: 201)
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.createProviderAccount(providerID: providerID, loginForm: loginForm, completion: { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let id):
                        XCTAssertEqual(id, 123)
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                        
                        do {
                            let fetchedAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedAccounts.count, 1)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testCreateProviderAccountsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_account_id_123")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let loginForm = ProviderLoginForm.loginFormFilledData()
            
            aggregation.createProviderAccount(providerID: 12345, loginForm: loginForm) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testDeleteProviderAccount() {
        let expectation1 = expectation(description: "Network Request")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.providerAccount(providerAccountID: 12345).path.prefixedWithSlash, addingStatusCode: 204)
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let providerAccount = ProviderAccount(context: managedObjectContext)
                providerAccount.populateTestData()
                providerAccount.providerAccountID = 12345
                
                try? managedObjectContext.save()
            }
            
            aggregation.deleteProviderAccount(providerAccountID: 12345) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNil(aggregation.providerAccount(context: self.context, providerAccountID: 12345))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }
    
    func testDeleteProviderAccountsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_account_id_123", addingStatusCode: 201)
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.deleteProviderAccount(providerAccountID: 12345) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testUpdateProviderAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountsUpdatedNotification, object: nil, handler: nil)
        
        let providerAccountID: Int64 = 123
        
        let loginForm = ProviderLoginForm.loginFormFilledData()
        
        connect(endpoint: AggregationEndpoint.providerAccount(providerAccountID: providerAccountID).path.prefixedWithSlash, toResourceWithName: "provider_account_id_123")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.updateProviderAccount(providerAccountID: providerAccountID, loginForm: loginForm) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                        
                        do {
                            let fetchedAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedAccounts.count, 1)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testUpdateProviderAccountsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_account_id_123", addingStatusCode: 201)
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let loginForm = ProviderLoginForm.loginFormFilledData()
            
            aggregation.updateProviderAccount(providerAccountID: 12345, loginForm: loginForm) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testProviderAccountsFetchMissingProviders() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid")
        connect(endpoint: AggregationEndpoint.provider(providerID: 12345).path.prefixedWithSlash, toResourceWithName: "provider_id_12345")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshProviderAccounts { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
            
            do {
                let fetchedProviderAccounts = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedProviderAccounts.count, 4)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let providerFetchRequest: NSFetchRequest<Provider> = Provider.fetchRequest()
            
            do {
                let fetchedProviders = try context.fetch(providerFetchRequest)
                
                XCTAssertEqual(fetchedProviders.count, 1)
                
                if let provider = fetchedProviders.first {
                    XCTAssertEqual(provider.providerID, 12345)
                    XCTAssertEqual(provider.providerAccounts?.count, 1)
                } else {
                    XCTFail("No provider")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 6.0)
        
    }
    
    func testSyncProviderAccounts() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        let notificationExpectation = expectation(forNotification: Aggregation.providerAccountsUpdatedNotification, object: nil, handler: nil)
         
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid_sync")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.syncProviderAccounts(providerAccountIDs: [22,33]) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 2)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        aggregation.syncProviderAccounts(providerAccountIDs: [22,33]) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                    
                    do {
                        let fetchedProviderAccounts = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedProviderAccounts.count, 2, "Provider Accounts Duplicated")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3, notificationExpectation], timeout: 3.0)
        
    }
    
    // MARK: - Account Tests
    
    func testFetchAccountByID() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testAccount = Account(context: managedObjectContext)
                testAccount.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let account = aggregation.account(context: self.context, accountID: id)
            
            XCTAssertNotNil(account)
            XCTAssertEqual(account?.accountID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAccounts() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testAccount1 = Account(context: managedObjectContext)
                testAccount1.populateTestData()
                testAccount1.providerAccountID = 69
                
                let testAccount2 = Account(context: managedObjectContext)
                testAccount2.populateTestData()
                testAccount2.providerAccountID = 12
                
                let testAccount3 = Account(context: managedObjectContext)
                testAccount3.populateTestData()
                testAccount3.providerAccountID = 69
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "providerAccountID == 69", argumentArray: nil)
            let accounts = aggregation.accounts(context: self.context, filteredBy: predicate)
            
            XCTAssertNotNil(accounts)
            XCTAssertEqual(accounts?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAccountsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testAccount1 = Account(context: managedObjectContext)
                testAccount1.populateTestData()
                testAccount1.providerAccountID = 69
                
                let testAccount2 = Account(context: managedObjectContext)
                testAccount2.populateTestData()
                testAccount2.providerAccountID = 12
                
                let testAccount3 = Account(context: managedObjectContext)
                testAccount3.populateTestData()
                testAccount3.providerAccountID = 69
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "providerAccountID == 69", argumentArray: nil)
            let fetchedResultsController = aggregation.accountsFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshAccountsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.accountsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.accounts.path.prefixedWithSlash, toResourceWithName: "accounts_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshAccounts { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                        
                        do {
                            let fetchedAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedAccounts.count, 8)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshAccountsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "accounts_valid")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshAccounts { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshAccountByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.accountsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshAccount(accountID: 542) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
                        
                        do {
                            let fetchedProviderAccounts = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedProviderAccounts.first?.accountID, 542)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
    }
    
    func testRefreshAccountByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshAccount(accountID: 542) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testAccountsLinkToProviderAccounts() {
        let expectation1 = expectation(description: "Database Request")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid")
        connect(endpoint: AggregationEndpoint.accounts.path.prefixedWithSlash, toResourceWithName: "accounts_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshProviderAccounts { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        aggregation.refreshAccounts { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        let context = database.viewContext
        
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
        
        do {
            let fetchedAccounts = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedAccounts.count, 1)
            
            if let account = fetchedAccounts.first {
                XCTAssertNotNil(account.providerAccount)
                XCTAssertEqual(account.providerAccountID, account.providerAccount?.providerAccountID)
                XCTAssertEqual(account.providerName, "ME Bank (demo)")
                XCTAssertEqual(account.productsAvailable, true)
                XCTAssertEqual(account.productDetailsPageURL, "www.example.com/product_details")
                XCTAssertEqual(account.productName, "Everyday Saver")
                XCTAssertEqual(account.productID, 1)
                XCTAssertEqual(account.productInformations?.count, 1)
                XCTAssertEqual(account.productInformations?.first?.name, "Benefits")
                XCTAssertEqual(account.productInformations?.first?.value, "Free ATMs")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testUpdatingAccount() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.accountsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let account = Account(context: managedObjectContext)
                account.populateTestData()
                account.accountID = 542
                
                try? managedObjectContext.save()
                
                aggregation.updateAccount(accountID: 542) { result in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.context
                            
                            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "accountID == %ld", argumentArray: [542])
                            
                            do {
                                let fetchedProviderAccounts = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedProviderAccounts.first?.accountID, 542)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testUpdateAccountByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let account = Account(context: managedObjectContext)
                account.populateTestData()
                account.accountID = 542
                
                try? managedObjectContext.save()
            
                aggregation.updateAccount(accountID: 542) { result in
                    switch result {
                        case .failure(let error):
                            XCTAssertNotNil(error)
                            
                            if let loggedOutError = error as? DataError {
                                XCTAssertEqual(loggedOutError.type, .authentication)
                                XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                            } else {
                                XCTFail("Wrong error type returned")
                            }
                        case .success:
                            XCTFail("User logged out, request should fail")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    // MARK: - Transaction Tests
    
    func testFetchTransactionByID() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testTransaction = Transaction(context: managedObjectContext)
                testTransaction.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let transaction = aggregation.transaction(context: self.context, transactionID: id)
            
            XCTAssertNotNil(transaction)
            XCTAssertEqual(transaction?.transactionID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactions() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTransaction1 = Transaction(context: managedObjectContext)
                testTransaction1.populateTestData()
                testTransaction1.baseType = .debit
                
                let testTransaction2 = Transaction(context: managedObjectContext)
                testTransaction2.populateTestData()
                testTransaction2.baseType = .credit
                
                let testTransaction3 = Transaction(context: managedObjectContext)
                testTransaction3.populateTestData()
                testTransaction3.baseType = .debit
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "baseTypeRawValue == %@", argumentArray: [Transaction.BaseType.credit.rawValue])
            let transactions = aggregation.transactions(context: self.context, filteredBy: predicate)
            
            XCTAssertNotNil(transactions)
            XCTAssertEqual(transactions?.count, 1)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTransactionsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTransaction1 = Transaction(context: managedObjectContext)
                testTransaction1.populateTestData()
                testTransaction1.baseType = .debit
                
                let testTransaction2 = Transaction(context: managedObjectContext)
                testTransaction2.populateTestData()
                testTransaction2.baseType = .credit
                testTransaction2.postDate = Date(timeIntervalSinceNow: -10)
                
                let testTransaction3 = Transaction(context: managedObjectContext)
                testTransaction3.populateTestData()
                testTransaction3.baseType = .debit
                
                let testTransaction4 = Transaction(context: managedObjectContext)
                testTransaction4.populateTestData()
                testTransaction4.baseType = .credit
                testTransaction4.postDate = Date(timeIntervalSinceNow: -432000)
                
                let testTransaction5 = Transaction(context: managedObjectContext)
                testTransaction5.populateTestData()
                testTransaction5.baseType = .credit
                testTransaction5.postDate = Date(timeIntervalSinceNow: -172800)
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "baseTypeRawValue == %@", argumentArray: [Transaction.BaseType.credit.rawValue])
            let fetchedResultsController = aggregation.transactionsFetchedResultsController(context: self.context, filteredBy: predicate, sectionNameKeypath: "sectionDate")
            
            do {
                try fetchedResultsController?.performFetch()
                XCTAssertEqual(fetchedResultsController?.sections?.count, 3)
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 3)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTransactionsFetchedResultsControllerSearchByAmount() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTransaction1 = Transaction(context: managedObjectContext)
                testTransaction1.populateTestData()
                testTransaction1.baseType = .debit
                testTransaction1.searchAmount = "28.00"
                
                let testTransaction2 = Transaction(context: managedObjectContext)
                testTransaction2.populateTestData()
                testTransaction2.baseType = .credit
                testTransaction2.searchAmount = "8.00"
                
                let testTransaction3 = Transaction(context: managedObjectContext)
                testTransaction3.populateTestData()
                testTransaction3.baseType = .debit
                testTransaction3.searchAmount = "128.00"
                
                let testTransaction4 = Transaction(context: managedObjectContext)
                testTransaction4.populateTestData()
                testTransaction4.baseType = .credit
                testTransaction4.searchAmount = "-28.00"
                
                let testTransaction5 = Transaction(context: managedObjectContext)
                testTransaction5.populateTestData()
                testTransaction5.baseType = .credit
                testTransaction5.searchAmount = "28.04"
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "searchAmount BEGINSWITH[cd] %@ || searchAmount BEGINSWITH[cd] %@", argumentArray: ["28.00", "-28.00"])
            
            
            let fetchedResultsController = aggregation.transactionsFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshTransactionsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
                        
            aggregation.refreshTransactions() { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 34)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 10.0)
        
    }
        
    func testRefreshTransactionsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_2018-08-01_valid")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
                        
            aggregation.refreshTransactions() { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshTransactionsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_2018-08-01_invalid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
                        
            aggregation.refreshTransactions() { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 30)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
        
    func testRefreshTransactionByIDIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransaction(transactionID: 194630) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    
    func testFetchPaginatedTransactions() {
        
        let expectation1 = expectation(description: "Database")
        let expectation2 = expectation(description: "Network Request Page 1")
        let expectation3 = expectation(description: "Fetch Request Page 1")
        let expectation4 = expectation(description: "Network Request Page 2")
        let expectation5 = expectation(description: "Fetch Request Page 2")
        
        let transactionStub = connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_page_1")
                
        var transactionFilter = TransactionFilter()
        transactionFilter.fromDate = "2019-07-26"
        transactionFilter.toDate = "2020-01-31"
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)

            let context = self.context

            context.performAndWait {
                let transaction1 = Transaction(context: context)
                transaction1.populateTestData()
                transaction1.transactionID = 164438
                transaction1.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-11-11")!
                transaction1.originalDescription = "Updating transaction"

                let transaction2 = Transaction(context: context)
                transaction2.populateTestData()
                transaction2.transactionID = 600
                transaction2.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-08-12")!
                transaction2.userDescription = "Deleting transaction"

                let transaction3 = Transaction(context: context)
                transaction3.populateTestData()
                transaction3.transactionID = 500
                transaction3.transactionDate = Transaction.transactionDateFormatter.date(from: "2019-06-11")!
                transaction3.userDescription = "Ignored transaction"

                try! context.save()
            }

            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshTransactions(transactionFilter: transactionFilter) { (result) in
            
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let paginationSuccess):
                    XCTAssertEqual(paginationSuccess.before, nil)
                    XCTAssertEqual(paginationSuccess.after, "1564138032_160746")
                    XCTAssertEqual(paginationSuccess.afterID, 160808)
                    XCTAssertEqual(paginationSuccess.afterDate, "2019-10-31")
                    transactionFilter.after = paginationSuccess.after
            }
            
             expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 10.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            
            do {
                
                let fetchedTransactions = try context.fetch(fetchRequest)
                let updatedTransaction = aggregation.transaction(context: context, transactionID: 160142)
                XCTAssertEqual(updatedTransaction?.originalDescription, "BURGER PROJECT SYDNEY AU")
                
                XCTAssertEqual(fetchedTransactions.count, 202)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        OHHTTPStubs.removeStub(transactionStub)

        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_page_2")

        aggregation.refreshTransactions(transactionFilter: transactionFilter) { (result) in

            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let paginationSuccess):
                    XCTAssertEqual(paginationSuccess.before, "1564051625_160540")
                    XCTAssertEqual(paginationSuccess.beforeID, 160540)
                    XCTAssertEqual(paginationSuccess.beforeDate, "2019-07-25")
                    XCTAssertEqual(paginationSuccess.after, nil)
                    transactionFilter.after = paginationSuccess.after
            }

             expectation4.fulfill()
        }

        wait(for: [expectation4], timeout: 3.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context

            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()

            do {
                let fetchedTransactions = try context.fetch(fetchRequest)

                XCTAssertEqual(fetchedTransactions.count, 399)
                XCTAssertNotNil(aggregation.transaction(context: self.context, transactionID: 161135))

            } catch {
                XCTFail(error.localizedDescription)
            }

            expectation5.fulfill()
        }

        wait(for: [expectation5], timeout: 3.0)
        
    }
    
    func testRefreshTransactionByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransaction(transactionID: 194630) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshTransactionByIDsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        let transactions: [Int64] = [1, 2, 3, 4, 5]
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransactions(transactionIDs: transactions) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 34)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshTransactionByIDsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let transactions: [Int64] = [1, 2, 3, 4, 5]
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransactions(transactionIDs: transactions) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionsLinkToAccounts() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Account Request")
        let expectation3 = expectation(description: "Network Transaction Request")
        
        connect(endpoint: AggregationEndpoint.accounts.path.prefixedWithSlash, toResourceWithName: "accounts_valid")
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshAccounts { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        aggregation.refreshTransactions() { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        let context = self.context
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [165379])
        
        do {
            let fetchedTransactions = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedTransactions.count, 1)
            
            if let transaction = fetchedTransactions.first {
                XCTAssertNotNil(transaction)
                
                XCTAssertEqual(transaction.accountID, transaction.account?.accountID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        
    }
    
    func testTransactionsLinkToMerchants() {
        let expectation1 = expectation(description: "Network Merchant Request")
        let expectation2 = expectation(description: "Network Transaction Request")
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_by_id")
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
                        
            aggregation.refreshTransactions() { result in
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [165266])
            
            do {
                let fetchedTransactions = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedTransactions.count, 1)
                
                if let transaction = fetchedTransactions.first {
                    XCTAssertNotNil(transaction)
                    
                    XCTAssertEqual(transaction.merchantID, transaction.merchant?.merchantID)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 8.0)
        
    }
    
    func testTransactionsLinkToTransactionCategories() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Transaction Category Request")
        let expectation3 = expectation(description: "Network Transaction Request")
        
        connect(endpoint: AggregationEndpoint.transactionCategories.path.prefixedWithSlash, toResourceWithName: "transaction_categories_valid")
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshTransactionCategories { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
                
        aggregation.refreshTransactions() { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        let context = self.context
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [164525])
        
        do {
            let fetchedTransactions = try context.fetch(fetchRequest)
            
            XCTAssertEqual(fetchedTransactions.count, 1)
            
            if let transaction = fetchedTransactions.first {
                XCTAssertNotNil(transaction)
                
                XCTAssertEqual(transaction.transactionCategoryID, transaction.transactionCategory?.transactionCategoryID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        
    }
    
    func testExcludeTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630_excluded")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                transaction.included = true
                
                try? managedObjectContext.save()
                
                aggregation.excludeTransaction(transactionID: 194630, excluded: true, excludeAll: true) { result in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.context
                            
                            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                            
                            do {
                                let fetchedTransactions = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                                XCTAssertEqual(fetchedTransactions.first?.included, false)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 5.0)
        
    }
    
    func testRecategoriseTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                transaction.transactionCategoryID = 123
                
                let oldTransactionCategory = TransactionCategory(context: managedObjectContext)
                oldTransactionCategory.populateTestData()
                oldTransactionCategory.transactionCategoryID = 123
                
                transaction.transactionCategory = oldTransactionCategory
                
                let newTransactionCategory = TransactionCategory(context: managedObjectContext)
                newTransactionCategory.populateTestData()
                newTransactionCategory.transactionCategoryID = 77
                
                try? managedObjectContext.save()
                
                aggregation.recategoriseTransaction(transactionID: 194630, transactionCategoryID: 77, recategoriseAll: true) { result in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.context
                            
                            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                            
                            do {
                                let fetchedTransactions = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                                XCTAssertEqual(fetchedTransactions.first?.transactionCategoryID, 77)
                                XCTAssertEqual(fetchedTransactions.first?.transactionCategory?.transactionCategoryID, 77)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 5.0)
        
    }
    
    func testUpdatingTransaction() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                
                try? managedObjectContext.save()
                
                aggregation.updateTransaction(transactionID: 194630) { result in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.context
                            
                            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [194630])
                            
                            do {
                                let fetchedTransactions = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedTransactions.first?.transactionID, 194630)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 5.0)
        
    }
    
    func testUpdateTransactionFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 194630
                
                try? managedObjectContext.save()
            
                aggregation.updateTransaction(transactionID: 194630) { result in
                    switch result {
                        case .failure(let error):
                            XCTAssertNotNil(error)
                            
                            if let loggedOutError = error as? DataError {
                                XCTAssertEqual(loggedOutError.type, .authentication)
                                XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                            } else {
                                XCTFail("Wrong error type returned")
                            }
                        case .success:
                            XCTFail("User logged out, request should fail")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionsFetchMissingMerchants() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_by_id")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshTransactions() { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            
            do {
                let fetchedTransactions = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedTransactions.count, 34)
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            let merchantFetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
            merchantFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]
            
            do {
                let fetchedMerchants = try context.fetch(merchantFetchRequest)
                
                XCTAssertEqual(fetchedMerchants.count, 2)
                
                if let merchant = fetchedMerchants.first {
                    XCTAssertEqual(merchant.merchantID, 238)
                } else {
                    XCTFail("No merchant")
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 8.0)
        
    }
    
    func testTransactionSearch() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transactionSearch.path.prefixedWithSlash, toResourceWithName: "transactions_search")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2019-03-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2019-04-30")!
            
            aggregation.transactionSearch(searchTerm: "Occidental", page: 0, from: fromDate, to: toDate, accountIDs: [544], onlyIncludedAccounts: true) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let transactionIDs):
                        XCTAssertEqual(transactionIDs, [194611, 194620, 194619, 194621])
                        
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [transactionIDs])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions.count, 4)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testTransactionSearchFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionSearch.path.prefixedWithSlash, toResourceWithName: "transactions_search")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2019-03-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2019-04-30")!
            
            aggregation.transactionSearch(searchTerm: "Occidental", page: 0, from: fromDate, to: toDate, accountIDs: [544], onlyIncludedAccounts: true) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionSummary() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionSummary.path.prefixedWithSlash, toResourceWithName: "transaction_summary")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2018-08-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2018-08-31")!
            
            aggregation.transactionSummary(from: fromDate, to: toDate, accountIDs: [123], transactionIDs: [1, 4, 5, 99, 100], onlyIncludedAccounts: false, onlyIncludedTransactions: false) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let summary):
                        XCTAssertEqual(summary.count, 5)
                        XCTAssertEqual(summary.sum, 45.98)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionSummaryFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionSummary.path.prefixedWithSlash, toResourceWithName: "transaction_summary")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let fromDate = Transaction.transactionDateFormatter.date(from: "2019-03-01")!
            let toDate = Transaction.transactionDateFormatter.date(from: "2019-04-30")!
            
            aggregation.transactionSummary(from: fromDate, to: toDate, accountIDs: [123], transactionIDs: [1, 4, 5, 99, 100], onlyIncludedAccounts: false, onlyIncludedTransactions: false) { result in
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    // MARK: - Transaction Category Tests
    
    func testFetchTransactionCategoryByID() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testTransactionCategory = TransactionCategory(context: managedObjectContext)
                testTransactionCategory.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let transactionCategory = aggregation.transactionCategory(context: self.context, transactionCategoryID: id)
            
            XCTAssertNotNil(transactionCategory)
            XCTAssertEqual(transactionCategory?.transactionCategoryID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategories() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTransactionCategory1 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory1.populateTestData()
                testTransactionCategory1.categoryType = .transfer
                
                let testTransactionCategory2 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory2.populateTestData()
                testTransactionCategory2.categoryType = .expense
                
                let testTransactionCategory3 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory3.populateTestData()
                testTransactionCategory3.categoryType = .expense
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "categoryTypeRawValue == %@", argumentArray: [TransactionCategory.CategoryType.expense.rawValue])
            let transactionCategories = aggregation.transactionCategories(context: self.context, filteredBy: predicate)
            
            XCTAssertNotNil(transactionCategories)
            XCTAssertEqual(transactionCategories?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTransactionCategoriesFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTransactionCategory1 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory1.populateTestData()
                testTransactionCategory1.categoryType = .transfer
                
                let testTransactionCategory2 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory2.populateTestData()
                testTransactionCategory2.categoryType = .expense
                
                let testTransactionCategory3 = TransactionCategory(context: managedObjectContext)
                testTransactionCategory3.populateTestData()
                testTransactionCategory3.categoryType = .expense
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "categoryTypeRawValue == %@", argumentArray: [TransactionCategory.CategoryType.expense.rawValue])
            let fetchedResultsController = aggregation.transactionCategoriesFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshTransactionCategoriesIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.transactionCategoriesUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.transactionCategories.path.prefixedWithSlash, toResourceWithName: "transaction_categories_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransactionCategories { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()
                        
                        do {
                            let fetchedTransactionCategories = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactionCategories.count, 63)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshTransactionCategoriesFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionCategories.path.prefixedWithSlash, toResourceWithName: "transaction_categories_valid")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransactionCategories() { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    // MARK: - Transaction Tags Tests
    
    func testRefreshTransactionUserTagsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionUserTags.path.prefixedWithSlash, toResourceWithName: "transactions_user_tags")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            managedObjectContext.performAndWait {
                let testTag1 = Tag(context: managedObjectContext)
                testTag1.populateTestData()
                testTag1.name = "dinner"
                testTag1.count = 3

                let testTag3 = Tag(context: managedObjectContext)
                testTag3.populateTestData()
                testTag3.name = "Kinner"
                testTag3.count = 3
                
                try! managedObjectContext.save()
            }
            
            aggregation.refreshTransactionUserTags() { result in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<Tag> = Tag.tagFetchRequest()
                    
                    do {
                        let fetchedTransactions = try context.fetch(fetchRequest).sorted(by: { $0.name < $1.name })
                        
                        XCTAssertEqual(fetchedTransactions.count, 7)
                        XCTAssertEqual(fetchedTransactions.first?.name, "brew")
                        XCTAssertEqual(fetchedTransactions.first?.count, 2)
                        XCTAssertEqual(fetchedTransactions.last?.name, "tag with spaces")
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshTransactionUserTagsIsSynced() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Network Request 2")
        
        connect(endpoint: AggregationEndpoint.transactionUserTags.path.prefixedWithSlash, toResourceWithName: "transactions_user_tags")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 3.0)
            
        let managedObjectContext = self.database.newBackgroundContext()
        managedObjectContext.performAndWait {
            let testTag1 = Tag(context: managedObjectContext)
            testTag1.populateTestData()
            testTag1.name = "dinner"
            testTag1.count = 3

            let testTag3 = Tag(context: managedObjectContext)
            testTag3.populateTestData()
            testTag3.name = "Kinner"
            testTag3.count = 3
            
            try! managedObjectContext.save()
        }
        
        aggregation.refreshTransactionUserTags() { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<Tag> = Tag.tagFetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
                    
                    do {
                        let fetchedTransactions = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedTransactions.count, 7)
                        XCTAssertEqual(fetchedTransactions[1].name, "brewery")
                        XCTAssertEqual(fetchedTransactions[1].count, 17)
                        XCTAssertEqual(fetchedTransactions[6].name, "tag with spaces")
                        XCTAssertEqual(fetchedTransactions[6].count, 1)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        connect(endpoint: AggregationEndpoint.transactionUserTags.path.prefixedWithSlash, toResourceWithName: "transactions_user_tags_expanded")
        
        aggregation.refreshTransactionUserTags() { result in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success:
                let context = self.context
                
                let fetchRequest: NSFetchRequest<Tag> = Tag.tagFetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
                
                do {
                    let fetchedTransactions = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedTransactions.count, 10)
                    XCTAssertEqual(fetchedTransactions[0].name, "Test")
                    XCTAssertEqual(fetchedTransactions[0].count, 1)
                    XCTAssertEqual(fetchedTransactions[6].name, "groceries")
                    XCTAssertEqual(fetchedTransactions[6].count, 2)
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
    }
    
    func testRefreshTransactionUserTagsInvalidResponse() {
        let expectation1 = expectation(description: "Network Request 1")
        let invalidStatusCode = 500
        
        connect(endpoint: AggregationEndpoint.transactionUserTags.path.prefixedWithSlash, toResourceWithName: "transactions_user_tags", addingStatusCode: invalidStatusCode)
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransactionUserTags() { result in
                switch result {
                case .failure:
                    break
                case .success:
                    XCTFail("Result should not be success")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionUserTags() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTag1 = Tag(context: managedObjectContext)
                testTag1.populateTestData()
                testTag1.name = "Repeated"
                testTag1.count = 1
                
                let testTag2 = Tag(context: managedObjectContext)
                testTag2.populateTestData()
                testTag2.name = "Repeated"
                testTag2.count = 2
                
                let testTag3 = Tag(context: managedObjectContext)
                testTag3.populateTestData()
                testTag3.count = 3
                
                try! managedObjectContext.save()
            }
            
            let userTags = aggregation.transactionUserTags(context: self.context)
            
            XCTAssertEqual(userTags?.count, 3)
            let sortedData = userTags?.sorted(by: { $0.count < $1.count })
            XCTAssertEqual(sortedData?.first?.count, 1)
            XCTAssertEqual(sortedData?.last?.count, 3)
            
            expectation1.fulfill()

        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAddTagToTransaction() {
        
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionTags(transactionID: 2233).path.prefixedWithSlash, toResourceWithName: "transaction_update_tag")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 2233
                transaction.userTags = ["Pub","Dinner"]
                
                try? managedObjectContext.save()
                
                var tuplearray = [Aggregation.tagApplyAllPairs]()
                tuplearray.append(("tagone",true))
                tuplearray.append(("tagtwo",true))
                
                aggregation.addTagToTransaction(transactionID: 2233, tagApplyAllPairs: tuplearray) { result in
                    
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [2233])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions[0].userTags.count, 4)
                            XCTAssertEqual(fetchedTransactions[0].userTags[2], "tagone")
                            XCTAssertEqual(fetchedTransactions[0].userTags[3], "tagtwo")
                           
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                    }
                    
                    expectation1.fulfill()
                }
                
            }
            
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    
    func testRemoveTagFromTransaction() {
        
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionTags(transactionID: 2233).path.prefixedWithSlash, toResourceWithName: "transaction_update_tag")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let transaction = Transaction(context: managedObjectContext)
                transaction.populateTestData()
                transaction.transactionID = 2233
                transaction.userTags = ["Pub","Dinner","tagone","tagtwo"]
                
                try? managedObjectContext.save()
                
                var tuplearray = [Aggregation.tagApplyAllPairs]()
                tuplearray.append(("tagone",true))
                tuplearray.append(("tagtwo",true))
                
                aggregation.removeTagFromTransaction(transactionID: 2233, tagApplyAllPairs: tuplearray) { result in
                    
                    switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [2233])
                        
                        do {
                            let fetchedTransactions = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedTransactions[0].userTags.count, 2)
                            
                            XCTAssertNotEqual(fetchedTransactions[0].userTags[0], "tagone")
                            XCTAssertNotEqual(fetchedTransactions[0].userTags[1], "tagone")
                            
                            XCTAssertNotEqual(fetchedTransactions[0].userTags[0], "tagtwo")
                            XCTAssertNotEqual(fetchedTransactions[0].userTags[1], "tagtwo")
                            
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                    }
                    
                    expectation1.fulfill()
                }
                
            }
         
        }
        
        wait(for: [expectation1], timeout: 3.0)
       
    }
    
    func testListTagsForTransaction() {
        
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionTags(transactionID: 2233).path.prefixedWithSlash, toResourceWithName: "transaction_update_tag")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.listAllTagsForTransaction(transactionID: 2233, completion: { (result) in
                
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                case .success(let response):
                    XCTAssertEqual(response.count, 2)
                }
                
                expectation1.fulfill()
                
            })

        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshTransactionUserTagsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionUserTags.path.prefixedWithSlash, toResourceWithName: "transactions_user_tags")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshTransactionUserTags() { result in
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionUserTagsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testTag1 = Tag(context: managedObjectContext)
                testTag1.populateTestData()
                testTag1.count = 1
                
                let testTag2 = Tag(context: managedObjectContext)
                testTag2.populateTestData()
                testTag2.count = 2
                
                let testTag3 = Tag(context: managedObjectContext)
                testTag3.populateTestData()
                testTag3.count = 3
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "count == 2", argumentArray: nil)
            let fetchedResultsController = aggregation.transactionUserTagsFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 1)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testTransactionSuggestedTags() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionSuggestedTags.path.prefixedWithSlash, toResourceWithName: "transactions_suggested_tags")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.transactionSuggestedTags(searchTerm: "term") { result in
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .loggedOut)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success(let data):
                    XCTAssertEqual(data.count, 5)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionSuggestedTagsRequestFails() {
        let expectation1 = expectation(description: "Network Request 1")
        let invalidStatusCode = 500
        
        connect(endpoint: AggregationEndpoint.transactionSuggestedTags.path.prefixedWithSlash, toResourceWithName: "transactions_suggested_tags", addingStatusCode: invalidStatusCode)
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.transactionSuggestedTags(searchTerm: "term") { result in
                switch result {
                case .failure:
                    break
                case .success:
                    XCTFail("Request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testTransactionSuggestedTagsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.transactionSuggestedTags.path.prefixedWithSlash, toResourceWithName: "transactions_suggested_tags")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.transactionSuggestedTags(searchTerm: "term") { result in
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    // MARK: - Merchant Tests
    
    func testFetchMerchantByID() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testMerchant = Merchant(context: managedObjectContext)
                testMerchant.populateTestData(withID: id)
                
                try! managedObjectContext.save()
            }
            
            let merchant = aggregation.merchant(context: self.context, merchantID: id)
            
            XCTAssertNotNil(merchant)
            XCTAssertEqual(merchant?.merchantID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchants() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testMerchant1 = Merchant(context: managedObjectContext)
                testMerchant1.populateTestData()
                testMerchant1.merchantType = .retailer
                
                let testMerchant2 = Merchant(context: managedObjectContext)
                testMerchant2.populateTestData()
                testMerchant2.merchantType = .retailer
                
                let testMerchant3 = Merchant(context: managedObjectContext)
                testMerchant3.populateTestData()
                testMerchant3.merchantType = .transactional
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "merchantTypeRawValue == %@", argumentArray: [Merchant.MerchantType.retailer.rawValue])
            let merchants = aggregation.merchants(context: self.context, filteredBy: predicate)
            
            XCTAssertNotNil(merchants)
            XCTAssertEqual(merchants?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchPaginatedMerchants() {
        
        let expectation1 = expectation(description: "Database")
        let expectation2 = expectation(description: "Network Request Page 1")
        let expectation3 = expectation(description: "Fetch Request Page 1")
        let expectation4 = expectation(description: "Network Request Page 2")
        let expectation5 = expectation(description: "Fetch Request Page 2")
        
        let merchantStub = connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchant_page_1")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let context = self.context
            
            context.performAndWait {
                let testMerchant1 = Merchant(context: context)
                testMerchant1.populateTestData()
                testMerchant1.merchantID = 11
                testMerchant1.name = "Updating merchant"
                
                let testMerchant2 = Merchant(context: context)
                testMerchant2.populateTestData()
                testMerchant2.merchantID = 78
                testMerchant2.name = "Deleting merchant"
                
                let testMerchant3 = Merchant(context: context)
                testMerchant3.populateTestData()
                testMerchant3.merchantID = 500
                testMerchant3.name = "Ignored merchant"
                
                try! context.save()
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        aggregation.refreshMerchants(size: 50) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let before, let after, let total):
                    XCTAssertEqual(before, "10")
                    XCTAssertEqual(after, "60")
                    XCTAssertEqual(total, 100)
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
            
            do {
                let fetchedMerchants = try context.fetch(fetchRequest)
                let updatedMerchant = aggregation.merchant(context: context, merchantID: 11)
                XCTAssertEqual(updatedMerchant?.name, "Xero")
                
                XCTAssertEqual(fetchedMerchants.count, 52)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 3.0)
        
        OHHTTPStubs.removeStub(merchantStub)
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchant_page_2")
        
         aggregation.refreshMerchants(after: "51", size: 50) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let before, let after, _):
                        XCTAssertEqual(before, "60")
                        XCTAssertEqual(after, "110")
                }
            
            XCTAssertNil(aggregation.merchant(context: self.context, merchantID: 78))
                   
            expectation4.fulfill()
        }
        
        wait(for: [expectation4], timeout: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context
            
            let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
            
            do {
                let fetchedMerchants = try context.fetch(fetchRequest)
                
                XCTAssertEqual(fetchedMerchants.count, 100)
                XCTAssertNotNil(aggregation.merchant(context: self.context, merchantID: 500))
                
            } catch {
                XCTFail(error.localizedDescription)
            }
                        
            expectation5.fulfill()
        }
        
        wait(for: [expectation5], timeout: 3.0)
        
    }
        
    func testMerchantsFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = self.database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testMerchant1 = Merchant(context: managedObjectContext)
                testMerchant1.populateTestData()
                testMerchant1.merchantType = .retailer
                
                let testMerchant2 = Merchant(context: managedObjectContext)
                testMerchant2.populateTestData()
                testMerchant2.merchantType = .retailer
                
                let testMerchant3 = Merchant(context: managedObjectContext)
                testMerchant3.populateTestData()
                testMerchant3.merchantType = .transactional
                
                try! managedObjectContext.save()
            }
            
            let predicate = NSPredicate(format: "merchantTypeRawValue == %@", argumentArray: [Merchant.MerchantType.retailer.rawValue])
            let fetchedResultsController = aggregation.merchantsFetchedResultsController(context: self.context, filteredBy: predicate)
            
            do {
                try fetchedResultsController?.performFetch()
                
                XCTAssertNotNil(fetchedResultsController?.fetchedObjects)
                XCTAssertEqual(fetchedResultsController?.fetchedObjects?.count, 2)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshMerchantsIsCached() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.merchantsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshMerchants { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                        
                        do {
                            let fetchedMerchants = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMerchants.count, 1199)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshMerchantsFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_valid")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshMerchants { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshMerchantByID() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.merchantsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.merchant(merchantID: 197).path.prefixedWithSlash, toResourceWithName: "merchant_id_197")
        
       let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshMerchant(merchantID: 197) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                        
                        do {
                            let fetchedMerchants = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMerchants.count, 1)
                            
                            if let merchant = fetchedMerchants.first {
                                XCTAssertEqual(merchant.merchantID, 197)
                            } else {
                                XCTFail("No merchant found")
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshMerchantByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.merchant(merchantID: 197).path.prefixedWithSlash, toResourceWithName: "merchant_id_197")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshMerchant(merchantID: 197) { result in
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    
                    if let loggedOutError = error as? DataError {
                        XCTAssertEqual(loggedOutError.type, .authentication)
                        XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testRefreshMerchantsByID() {
        let expectation1 = expectation(description: "Network Request 1")
        let notificationExpectation = expectation(forNotification: Aggregation.merchantsUpdatedNotification, object: nil, handler: nil)
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_by_id")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshMerchants(merchantIDs: [22, 30, 31, 106, 691]) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.context
                        
                        let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]
                        
                        do {
                            let fetchedMerchants = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMerchants.count, 2)
                            
                            if let merchant = fetchedMerchants.last {
                                XCTAssertEqual(merchant.merchantID, 686)
                            } else {
                                XCTFail("No merchants")
                            }
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, notificationExpectation], timeout: 3.0)
        
    }
    
    func testRefreshMerchantsByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_by_id")
        
        let aggregation = self.aggregation(loggedIn: false)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.refreshMerchants(merchantIDs: [22, 30, 31, 106, 691]) { result in
                switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        
                        if let loggedOutError = error as? DataError {
                            XCTAssertEqual(loggedOutError.type, .authentication)
                            XCTAssertEqual(loggedOutError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type returned")
                        }
                    case .success:
                        XCTFail("User logged out, request should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
    }
    
    func testCachedMerchantsRefresh() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        let expectation3 = expectation(description: "Fetch Request 1")

        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_valid")

        database.setup { (error) in
            XCTAssertNil(error)

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 5.0)

        // Insert stale data
        let managedObjectContext = self.database.newBackgroundContext()

        managedObjectContext.performAndWait {
            let cachedMerchant1 = Merchant(context: managedObjectContext)
            cachedMerchant1.populateTestData()
            cachedMerchant1.merchantID = 238

            let cachedMerchant2 = Merchant(context: managedObjectContext)
            cachedMerchant2.populateTestData()
            cachedMerchant2.merchantID = 239

            let cachedMerchant3 = Merchant(context: managedObjectContext)
            cachedMerchant3.populateTestData()
            cachedMerchant3.merchantID = 1257

            try! managedObjectContext.save()
        }

        let aggregation = self.aggregation(loggedIn: true)

        aggregation.refreshCachedMerchants { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                break
                    
            }

            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let context = self.context

            let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]

            do {
                let fetchedMerchants = try context.fetch(fetchRequest)

                XCTAssertEqual(fetchedMerchants.count, 1199)

                if let merchant = fetchedMerchants.last {
                    XCTAssertEqual(merchant.merchantID, 1258)
                    XCTAssertEqual(merchant.name, "Sushi 8")
                    XCTAssertEqual(merchant.merchantType, .retailer)
                } else {
                    XCTFail("No merchants")
                }

                let updatedMerchant = aggregation.merchant(context: context, merchantID: 238)
                XCTAssertEqual(updatedMerchant?.name, "The Occidental Hotel")

                let deletedMerchant = aggregation.merchant(context: context, merchantID: 1257)
                XCTAssertNil(deletedMerchant)

            } catch {
                XCTFail(error.localizedDescription)
            }
            
            expectation3.fulfill()
        }
        
        wait(for: [expectation3], timeout: 5.0)
    }
    
    func testrefreshMerchantWithCompletionHandler(){
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchant_page_2")
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        // Insert stale data
        let managedObjectContext = self.database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let cachedMerchant1 = Merchant(context: managedObjectContext)
            cachedMerchant1.populateTestData()
            cachedMerchant1.merchantID = 109
            
            let cachedMerchant2 = Merchant(context: managedObjectContext)
            cachedMerchant2.populateTestData()
            cachedMerchant2.merchantID = 78
            
            let cachedMerchant3 = Merchant(context: managedObjectContext)
            cachedMerchant3.populateTestData()
            cachedMerchant3.merchantID = 268
            
            try! managedObjectContext.save()
        }
        
        let aggregation = self.aggregation(loggedIn: true)
        
        aggregation.refreshMerchantsWithCompletionHandler(merchantIDs: []) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let before, let after, let total):
                    
                    XCTAssertEqual(before, "60")
                    XCTAssertEqual(after, "110")
                    XCTAssertEqual(total, 100)
                    
                    let context = self.context
                    
                    let fetchRequest: NSFetchRequest<Merchant> = Merchant.fetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.merchantID), ascending: true)]
                    
                    do {
                        let fetchedMerchants = try context.fetch(fetchRequest)
                        
                        XCTAssertEqual(fetchedMerchants.count, 51)
                        
                        let updatedMerchant = aggregation.merchant(context: context, merchantID: 109)
                        XCTAssertEqual(updatedMerchant?.name, "Dymocks")
                        
                        XCTAssertNotNil(aggregation.merchant(context: context, merchantID: 78))
                        
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
            }
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 3.0)
    }
    
    func testTransactionsRefreshedOnNotification() {
        let expectation1 = expectation(forNotification: Aggregation.transactionsUpdatedNotification, object: nil) { (_) -> Bool in
            true
        }
        
        let ids: [Int64] = [4, 87, 9077777]
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_2018-08-01_valid")
        
        database.setup { error in
            XCTAssertNil(error)
            
            NotificationCenter.default.post(name: Aggregation.refreshTransactionsNotification, object: self, userInfo: [Aggregation.refreshTransactionIDsKey: ids])
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testSearchMerchants() {
        let expectation1 = expectation(description: "Network Request 1")
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_valid")
        
        let aggregation = self.aggregation(loggedIn: true)
        
        database.setup { error in
            XCTAssertNil(error)
            
            aggregation.searchMerchants(keyword: "") { result in
                switch result{
                    case .success(let merchants):
                        XCTAssertEqual(merchants.data.count, 1199)
                        XCTAssertEqual(merchants.data.first?.merchantID, 1)
                        XCTAssertEqual(merchants.data.first?.merchantName, "Unknown")
                        XCTAssertEqual(merchants.data.first?.iconURL, "https://frollo-sandbox.s3.amazonaws.com/merchants/1/original/Untitled-1.png?1519084540")
                        XCTAssertEqual(merchants.after, "1258")
                        XCTAssertEqual(merchants.before, "1")
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    }
                
                    expectation1.fulfill()
                }
            }
        wait(for: [expectation1], timeout: 3.0)
    }
}


