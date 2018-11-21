//
//  MessagesTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class MessagesTests: XCTestCase, FrolloSDKDelegate {
    
    let keychainService = "MessagesTests"
    
    private var expectations = [XCTestExpectation]()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        expectations = []
        
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }
    
    func testRefreshMessages() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, network: network)
            
            messages.refreshMessages(completion: { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                
                do {
                    let fetchedMessages = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedMessages.count, 74)
                    
                    for message in fetchedMessages {
                        switch message.contentType {
                        case .html5:
                            XCTAssertTrue(message.isKind(of: MessageHTML.self))
                        case .textAndImage:
                            XCTAssertTrue(message.isKind(of: MessageImage.self))
                        case .text:
                            XCTAssertTrue(message.isKind(of: MessageText.self))
                        case .video:
                            XCTAssertTrue(message.isKind(of: MessageVideo.self))
                        }
                    }
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshMessageByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        let id: Int64 = 12345
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, network: network)
            
            messages.refreshMessage(messageID: id) { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "messageID == %ld", argumentArray: [id])
                
                do {
                    let fetchedMessages = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedMessages.first?.messageID, id)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateMessage() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let message = Message(context: managedObjectContext)
            message.populateTestData()
            message.messageID = 12345
            
            try? managedObjectContext.save()
            
            let messages = Messages(database: database, network: network)
            
            messages.updateMessage(messageID: 12345, completion: { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "messageID == %ld", argumentArray: [12345])
                
                do {
                    let fetchedMessages = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedMessages.first?.messageID, 12345)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateMessageNotFound() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let message = Message(context: managedObjectContext)
            message.populateTestData()
            message.messageID = 666
            
            try? managedObjectContext.save()
            
            let messages = Messages(database: database, network: network)
            
            messages.updateMessage(messageID: 12345, completion: { (error) in
                XCTAssertNotNil(error)
                
                if let dataError = error as? DataError {
                    XCTAssertEqual(dataError.type, .database)
                    XCTAssertEqual(dataError.subType, .notFound)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testRefreshUnreadMessages() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, network: network)
            
            messages.refreshUnreadMessages(completion: { (error) in
                XCTAssertNil(error)
                
                let context = database.viewContext
                
                let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                
                do {
                    let fetchedMessages = try context.fetch(fetchRequest)
                    
                    XCTAssertEqual(fetchedMessages.count, 7)
                    
                    for message in fetchedMessages {
                        switch message.contentType {
                            case .html5:
                                XCTAssertTrue(message.isKind(of: MessageHTML.self))
                            case .textAndImage:
                                XCTAssertTrue(message.isKind(of: MessageImage.self))
                            case .text:
                                XCTAssertTrue(message.isKind(of: MessageText.self))
                            case .video:
                                XCTAssertTrue(message.isKind(of: MessageVideo.self))
                        }
                        
                        XCTAssertFalse(message.read)
                    }
                } catch {
                    XCTFail(error.localizedDescription)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testHandlingPushMessageTriggersDelegate() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        let notificationPayload = NotificationPayload.testMessageData()
        
        stub(condition: isHost(url.host!) && isPath("/" + MessagesEndpoint.message(messageID: notificationPayload.userMessageID!).path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        let network = Network(serverURL: url, keychain: keychain)
        let messages = Messages(database: database, network: network)
        messages.delegate = self
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.expectations.append(expectation1)
            
            messages.handleMessageNotification(notificationPayload)
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    // MARK: - Delegate
    
    func messageReceived(_ messageID: Int64) {
        guard let expectation = expectations.first
            else {
                return
        }
        
        expectation.fulfill()
    }
    
    func eventTriggered(eventName: String) {
        // Stub
    }

}
