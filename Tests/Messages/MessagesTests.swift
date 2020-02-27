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
    
    func testFetchMessageByID() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            let id: Int64 = 12345
            
            managedObjectContext.performAndWait {
                let testMessage = Message(context: managedObjectContext)
                testMessage.populateTestData()
                testMessage.messageID = id
                
                try! managedObjectContext.save()
            }
            
            let messages = Messages(database: database, service: service)
            
            let message = messages.message(context: database.viewContext, messageID: id)
            
            XCTAssertNotNil(message)
            XCTAssertEqual(message?.messageID, id)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMessages() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testMessage1 = Message(context: managedObjectContext)
                testMessage1.populateTestData()
                testMessage1.contentType = .text
                testMessage1.messageTypes = ["information"]
                testMessage1.read = false
                
                let testMessage2 = Message(context: managedObjectContext)
                testMessage2.populateTestData()
                testMessage2.contentType = .text
                testMessage2.messageTypes = ["warning"]
                testMessage2.read = false
                
                let testMessage3 = Message(context: managedObjectContext)
                testMessage3.populateTestData()
                testMessage3.contentType = .text
                testMessage3.messageTypes = ["derp", "test"]
                testMessage3.read = false
                
                try! managedObjectContext.save()
            }
            
            let messages = Messages(database: database, service: service)
            
            let fetchedMessages = messages.messages(context: database.viewContext, contentType: .text, messageTypes: ["information", "warning"], unread: true)
            
            XCTAssertNotNil(fetchedMessages)
            XCTAssertEqual(fetchedMessages?.count, 2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testMessagesCount() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testMessage1 = Message(context: managedObjectContext)
                testMessage1.populateTestData()
                testMessage1.contentType = .text
                testMessage1.messageTypes = ["information"]
                testMessage1.read = false
                
                let testMessage2 = Message(context: managedObjectContext)
                testMessage2.populateTestData()
                testMessage2.contentType = .text
                testMessage2.messageTypes = ["warning"]
                testMessage2.read = false
                
                let testMessage3 = Message(context: managedObjectContext)
                testMessage3.populateTestData()
                testMessage3.contentType = .text
                testMessage3.messageTypes = ["derp", "test"]
                testMessage3.read = false
                
                try! managedObjectContext.save()
            }
            
            let messages = Messages(database: database, service: service)
            
            var fetchedMessagesCount = messages.messagesCount(context: database.viewContext)
            
            XCTAssertEqual(fetchedMessagesCount, 3)
            
            fetchedMessagesCount = messages.messagesCount(context: database.viewContext, unread: true, messageTypes: ["information", "warning"])
            
            XCTAssertEqual(fetchedMessagesCount, 2)
            
            let predicate = NSPredicate(format: #keyPath(Message.read) + " == %ld", argumentArray: [true])

            fetchedMessagesCount = messages.messagesCount(context: database.viewContext, filteredBy: predicate)
            
            XCTAssertEqual(fetchedMessagesCount, 0)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testMessagesFetchedResultsController() {
        let expectation1 = expectation(description: "Completion")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let testMessage1 = Message(context: managedObjectContext)
                testMessage1.populateTestData()
                testMessage1.contentType = .text
                testMessage1.read = false
                
                let testMessage2 = Message(context: managedObjectContext)
                testMessage2.populateTestData()
                testMessage2.contentType = .text
                testMessage2.messageTypes = ["derp", "test"]
                testMessage2.read = false
                
                let testMessage3 = Message(context: managedObjectContext)
                testMessage3.populateTestData()
                testMessage3.contentType = .text
                testMessage3.read = false
                
                try! managedObjectContext.save()
            }
            
            let messages = Messages(database: database, service: service)
            
            let fetchedResultsController = messages.messagesFetchedResultsController(context: database.viewContext, contentType: .text, messageTypes: ["information", "warning"], unread: true)
            
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
    
    func testRefreshMessages() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, service: service)
            
            messages.refreshMessages(completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                        
                        do {
                            let fetchedMessages = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMessages.count, 39)
                            
                            for message in fetchedMessages {
                                switch message.contentType {
                                    case .html:
                                        XCTAssertTrue(message.isKind(of: MessageHTML.self))
                                    case .image:
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
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshMessagesFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.messages.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_valid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { error in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, service: service)
            
            messages.refreshMessages { (result) in
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
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRefreshMessageByID() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let id: Int64 = 12345
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, service: service)
            
            messages.refreshMessage(messageID: id) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "messageID == %ld", argumentArray: [id])
                        
                        do {
                            let fetchedMessages = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMessages.first?.messageID, id)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshMessageByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let id: Int64 = 12345
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: id).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { error in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, service: service)
            
            messages.refreshMessage(messageID: id) { (result) in
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
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateMessage() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let message = Message(context: managedObjectContext)
                message.populateTestData()
                message.messageID = 12345
                
                try? managedObjectContext.save()
                
                let messages = Messages(database: database, service: service)
                
                messages.updateMessage(messageID: 12345, completion: { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = database.viewContext
                            
                            let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "messageID == %ld", argumentArray: [12345])
                            
                            do {
                                let fetchedMessages = try context.fetch(fetchRequest)
                                
                                XCTAssertEqual(fetchedMessages.first?.messageID, 12345)
                            } catch {
                                XCTFail(error.localizedDescription)
                            }
                    }
                    
                    expectation1.fulfill()
                })
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateMessageByIDFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { error in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let message = Message(context: managedObjectContext)
                message.populateTestData()
                message.messageID = 12345
                
                try? managedObjectContext.save()
            
                let messages = Messages(database: database, service: service)
                
                messages.updateMessage(messageID: 12345) { (result) in
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
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateMessageNotFound() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: 12345).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let managedObjectContext = database.newBackgroundContext()
            
            managedObjectContext.performAndWait {
                let message = Message(context: managedObjectContext)
                message.populateTestData()
                message.messageID = 666
                
                try? managedObjectContext.save()
                
                let messages = Messages(database: database, service: service)
                
                messages.updateMessage(messageID: 12345, completion: { (result) in
                    switch result {
                        case .failure(let error):
                            if let dataError = error as? DataError {
                                XCTAssertEqual(dataError.type, .database)
                                XCTAssertEqual(dataError.subType, .notFound)
                            } else {
                                XCTFail("Wrong error returned")
                            }
                        case .success:
                            XCTFail("Message should fail to be found")
                    }
                    
                    expectation1.fulfill()
                })
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testRefreshUnreadMessages() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, service: service)
            
            messages.refreshUnreadMessages { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = database.viewContext
                        
                        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
                        
                        do {
                            let fetchedMessages = try context.fetch(fetchRequest)
                            
                            XCTAssertEqual(fetchedMessages.count, 7)
                            
                            for message in fetchedMessages {
                                switch message.contentType {
                                    case .html:
                                        XCTAssertTrue(message.isKind(of: MessageHTML.self))
                                    case .image:
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
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshUnreadMessagesFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request 1")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.unread.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "messages_unread", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let mockAuthentication = MockAuthentication(valid: false)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let database = Database(path: tempFolderPath())
        
        database.setup { error in
            XCTAssertNil(error)
            
            let messages = Messages(database: database, service: service)
            
            messages.refreshUnreadMessages { (result) in
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
        OHHTTPStubs.removeAllStubs()
    }
    
    func testHandlingPushMessageTriggersDelegate() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        let notificationPayload = NotificationPayload.testMessageData()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + MessagesEndpoint.message(messageID: notificationPayload.userMessageID!).path)) { (request) -> OHHTTPStubsResponse in
            expectation1.fulfill()
            
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "message_id_12345", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let messages = Messages(database: database, service: service)
        messages.delegate = self
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            self.expectations.append(expectation1)
            
            messages.handleMessageNotification(notificationPayload)
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testMarkMessageReadFromHandlePushNotification() {
        
        let path = tempFolderPath()
        let database = Database(path: path)
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        let messages = Messages(database: database, service: service)
        let context = database.viewContext
        
        let managedObjectContext = database.newBackgroundContext()
        
        database.setup { (error) in
            XCTAssertNil(error)
                        
            managedObjectContext.performAndWait {
                let message = Message(context: managedObjectContext)
                message.populateTestData()
                message.messageID = 98765
                message.read = false
                message.interacted = false
                
                try? managedObjectContext.save()

            }
        }
        
        let notificationPayload = NotificationPayload.testMessageData()
        messages.handleMessageNotification(notificationPayload)
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "messageID == %ld", argumentArray: [98765])
        
        do {
            let fetchedMessages = try context.fetch(fetchRequest)
            XCTAssertTrue(fetchedMessages.first!.read)
            XCTAssertTrue(fetchedMessages.first!.interacted)
            XCTAssertEqual(fetchedMessages.first?.messageID, 98765)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
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
