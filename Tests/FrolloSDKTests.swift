//
//  FrolloSDKTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 26/6/18.
//

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class FrolloSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        removeDataFolder()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func populateTestDataNamed(name: String, atPath: URL) {
        let databaseFileURL = Bundle(for: type(of: self)).url(forResource: name, withExtension: "sqlite")!
        let databaseSHMFileURL = databaseFileURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        let databaseWALFileURL = databaseFileURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let databaseFiles = [databaseFileURL, databaseSHMFileURL, databaseWALFileURL]
        for file in databaseFiles {
            let destinationURL = atPath.appendingPathComponent(Database.DatabaseConstants.storeName).appendingPathExtension(file.pathExtension)
            try! FileManager.default.copyItem(at: file, to: destinationURL)
        }
    }
    
    func checkDatabaseEmpty(database: Database) {
        let context = database.viewContext
        
        for entity in database.persistentContainer.managedObjectModel.entities {
            guard let entityName = entity.name
                else {
                    continue
            }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            fetchRequest.resultType = .dictionaryResultType
            
            let results = try! context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 0)
        }
    }
    
    func removeDataFolder() {
        // Remove app data folder from disk
        try? FileManager.default.removeItem(atPath: Frollo.defaultDataFolderURL.path)
        try? FileManager.default.removeItem(at: FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!)
    }
    
    // MARK: - Tests
    
    func testSDKCreatesDefaultDataFolder() {
        let expectation1 = expectation(description: "Setup")
        
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(FileManager.default.fileExists(atPath: Frollo.defaultDataFolderURL.path))
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKCreatesCustomDataFolder() {
        let expectation1 = expectation(description: "Setup")
        
        #if os(tvOS)
        let dataDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("TestFolder")
        #else
        let dataDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!
        #endif
        
        let config = FrolloSDKConfiguration(authenticationType: .oAuth2(redirectURL: FrolloSDKConfiguration.redirectURL,
                                                                        authorizationEndpoint: FrolloSDKConfiguration.authorizationEndpoint,
                                                                        tokenEndpoint: FrolloSDKConfiguration.tokenEndpoint,
                                                                        revokeTokenEndpoint: FrolloSDKConfiguration.revokeTokenEndpoint),
                                            clientID: "abc123",
                                            dataDirectory: dataDirectory,
                                            serverEndpoint: URL(string: "https://api.example.com")!)
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(FileManager.default.fileExists(atPath: dataDirectory.path))
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKInitServerURLIsSet() {
        let expectation1 = expectation(description: "Setup")
        
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertEqual(sdk.network.serverURL, config.serverEndpoint)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKSetupSuccess() {
        let expectation1 = expectation(description: "Setup")
        
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(sdk.setup)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKResetSuccess() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config){ (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    sdk.reset { (result) in
                        switch result {
                            case .failure(let error):
                                XCTFail(error.localizedDescription)
                            case .success:
                                self.checkDatabaseEmpty(database: sdk.database)
                        }
                        
                        expectation1.fulfill()
                    }
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testPauseScheduledRefresh() {
        let expectation1 = expectation(description: "Setup")
        
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    sdk.applicationDidEnterBackground()
                    
                    XCTAssertNil(sdk.refreshTimer)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testResumeScheduledRefresh() {
        let expectation1 = expectation(description: "Setup")
        
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    sdk.applicationWillEnterForeground()
                    
                    XCTAssertNotNil(sdk.refreshTimer)
            }
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshData() {
        let expectation1 = expectation(description: "Setup")
        let expectation2 = expectation(description: "Setup")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(FrolloSDKConfiguration.tokenEndpoint.host!) && isPath(FrolloSDKConfiguration.tokenEndpoint.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "token_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + BillsEndpoint.billPayments.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "bill_payments_2018-12-01_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let sdk = Frollo()
        
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    sdk.defaultAuthentication?.loginUser(email: "user@example.com", password: "password", scopes: ["offline_access", "email", "openid"], completion: { (error) in
                        sdk.refreshData()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            let context = sdk.database.viewContext
                            
                            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                            
                            do {
                                let fetchedUsers = try context.fetch(userFetchRequest)
                                
                                XCTAssertTrue(fetchedUsers.count > 0)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            let providerAccountFetchRequest: NSFetchRequest<ProviderAccount> = ProviderAccount.fetchRequest()
                            
                            do {
                                let fetchedProviderAccounts = try context.fetch(providerAccountFetchRequest)
                                
                                XCTAssertTrue(fetchedProviderAccounts.count > 0)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            let accountFetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
                            
                            do {
                                let fetchedUsers = try context.fetch(accountFetchRequest)
                                
                                XCTAssertTrue(fetchedUsers.count > 0)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            let transactionFetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                            
                            do {
                                let fetchedTransactions = try context.fetch(transactionFetchRequest)
                                
                                XCTAssertTrue(fetchedTransactions.count > 0)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            let messageFetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                            
                            do {
                                let fetchedMessages = try context.fetch(messageFetchRequest)
                                
                                XCTAssertTrue(fetchedMessages.count > 0)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            expectation1.fulfill()
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                            let context = sdk.database.viewContext
                            
                            let billPaymentFetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                            
                            do {
                                let fetchedBillPayments = try context.fetch(billPaymentFetchRequest)
                                
                                XCTAssertTrue(fetchedBillPayments.count > 0)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                            
                            expectation2.fulfill()
                        })
                    })
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 15.0)
    }
    
    func testSingletonInstantiatedOnce() {
        XCTAssertTrue(Frollo.shared === Frollo.shared)
    }
    
    func testEnablePublicKeyPinning() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = true
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDisablePublicKeyPinning() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAggregationAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.aggregation
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAuthenticationAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.authentication
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testBillsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.bills
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testEventsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.events
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testGoalsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.goals
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testMessagesAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.messages
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testNotificationsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                _ = sdk.notifications
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testReportsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    _ = sdk.reports
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSetupInvokesDatabaseMigration() {
        let expectation1 = expectation(description: "Setup")
        
        try? FileManager.default.createDirectory(at: Frollo.defaultDataFolderURL, withIntermediateDirectories: true, attributes: nil)
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        
        populateTestDataNamed(name: "FrolloSDKDataModel-1.0.0", atPath: Frollo.defaultDataFolderURL)
        
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertFalse(sdk.database.needsMigration())
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testReset() {
        let expectation1 = expectation(description: "Setup")
        
        try? FileManager.default.createDirectory(at: Frollo.defaultDataFolderURL, withIntermediateDirectories: true, attributes: nil)
        
        var config = FrolloSDKConfiguration.testConfig()
        config.publicKeyPinningEnabled = false
        
        let sdk = Frollo()
        
        populateTestDataNamed(name: "FrolloSDKDataModel-1.2.0", atPath: Frollo.defaultDataFolderURL)
        
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    
                    sdk.reset()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                        self.checkDatabaseEmpty(database: sdk.database)
                        
                        expectation1.fulfill()
                    })
            }
        }
        
        wait(for: [expectation1], timeout: 10.0)
    }
    
    func testSDKCustomDataFolder() {
        
    }
    
}
