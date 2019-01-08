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
    
    func removeDataFolder() {
        // Remove app data folder from disk
        try? FileManager.default.removeItem(atPath: FrolloSDK.dataFolderURL.path)
    }
    
    // MARK: - Tests
    
    func testSDKCreatesDataFolder() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            XCTAssertTrue(FileManager.default.fileExists(atPath: FrolloSDK.dataFolderURL.path))
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKInitServerURLIsSet() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(sdk.network.serverURL, url)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKSetupSuccess() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            XCTAssertTrue(sdk.setup)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSDKResetSuccess() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!

        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.reset { (error) in
                XCTAssertNil(error)
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testPauseScheduledRefresh() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.applicationDidEnterBackground()
            
            XCTAssertNil(sdk.refreshTimer)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testResumeScheduledRefresh() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.applicationWillEnterForeground()
            
            XCTAssertNotNil(sdk.refreshTimer)
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshData() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.login.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(url.host!) && isPath("/" + UserEndpoint.details.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_details_complete", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let sdk = FrolloSDK()
        
        sdk.setup(serverURL: url) { (error) in
            XCTAssertNil(error)
            
            sdk.authentication.loginUser(method: .email, email: "user@example.com", password: "password", completion: { (error) in
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
            })
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testSingletonInstantiatedOnce() {
        XCTAssertTrue(FrolloSDK.shared === FrolloSDK.shared)
    }
    
    func testEnablePublicKeyPinning() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.frollo.us")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: true) { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDisablePublicKeyPinning() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.frollo.us")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAggregationAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            _ = sdk.aggregation
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testAuthenticationAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            _ = sdk.authentication
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testEventsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            _ = sdk.events
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testMessagesAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            _ = sdk.messages
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testNotificationsAfterSetup() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            _ = sdk.notifications
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSetupInvokesDatabaseMigration() {
        let expectation1 = expectation(description: "Setup")
        
        let url = URL(string: "https://api.example.com")!
        
        let sdk = FrolloSDK()
        
        populateTestDataNamed(name: "FrolloSDKDataModel-1.0.0", atPath: FrolloSDK.dataFolderURL)
        
        sdk.setup(serverURL: url, publicKeyPinningEnabled: false) { (error) in
            XCTAssertNil(error)
            
            XCTAssertFalse(sdk.database.needsMigration())
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 15.0)
    }
    
}
