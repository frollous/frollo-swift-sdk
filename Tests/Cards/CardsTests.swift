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
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif
@testable import FrolloSDK

class CardsTests: BaseTestCase {

    var aggregation: Aggregation!
    var cards: Cards!
    
    var keychain: Keychain!
    var authentication: Authentication!
    var network: Network!
    var service: APIService!

    override func setUp() {
        testsKeychainService = "CardsTests"
        super.setUp()

        keychain = defaultKeychain(isNetwork: true)
        authentication = defaultAuthentication(keychain: keychain)
        network = defaultNetwork(keychain: keychain, authentication: authentication)
        service = defaultService(keychain: keychain, authentication: authentication)
        let authService = defaultAuthService(keychain: keychain, network: network)

        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        aggregation = Aggregation(database: database, service: service)

        cards = Cards(database: database, service: service, aggregation: aggregation)
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testCreateCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.cards.path) && isMethodPOST()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_card", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            self.cards.createCard(accountID: 325, firstName: "Jacob", lastName: "Smith", streetNumber: "41-45", streetName: "Belmore Street", streetType: "Street", postalAddressSuburb: "Mock Suburb", postalCode: "123456", postalAddressState: "NSW", postalAddressCountry: "Australia") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [2])

                        do {
                            let fetchedCards = try context.fetch(fetchRequest)

                            XCTAssertEqual(fetchedCards.first?.cardID, 2)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }
    
    func testCreateCardFail() {
        let expectation1 = expectation(description: "Network Request 1")
        
        network = invalidNetwork(authentication: authentication)
        service = invalidService(keychain: keychain)
        let authService = defaultAuthService(keychain: keychain, network: network)

        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        aggregation = Aggregation(database: database, service: service)

        cards = Cards(database: database, service: service, aggregation: aggregation)
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.cards.path) && isMethodPOST()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "create_card", ofType: "json")!, status: 201, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            self.cards.createCard(accountID: 325, firstName: "Jacob", lastName: "Smith", streetNumber: "41-45", streetName: "Belmore Street", streetType: "Street", postalAddressSuburb: "Mock Suburb", postalCode: "123456", postalAddressState: "NSW", postalAddressCountry: "Australia") { (result) in
                switch result {
                case .failure(let error):
                    XCTAssertTrue(error is DataError)
                    if let error = error as? DataError {
                        XCTAssertEqual(error.type, DataError.DataErrorType.api)
                        XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                    }
                case .success:
                    XCTFail("Invalid service throw Error when encoding")
                }
                
                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
        HTTPStubs.removeAllStubs()
    }

    func testRefreshCards() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.cards.path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_cards", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)


            self.cards.refreshCards() { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Card.cardID), ascending: true)]
                        do {
                            let fetchedCards = try context.fetch(fetchRequest)
                            XCTAssertEqual(fetchedCards.count, 2)

                            XCTAssertEqual(fetchedCards.first?.cardID, 123)
                            XCTAssertEqual(fetchedCards.first?.accountID, 542)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshCardsFail() {
        let expectation1 = expectation(description: "Network Request 1")
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.cards.path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_cards", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)


            self.cards.refreshCards() { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is APIError)
                        if let error = error as? APIError {
                            XCTAssertEqual(error.statusCode, 404)
                        }
                    case .success:
                        XCTFail("Data response is invalid")
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    

    func testRefreshCardByID() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_card_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)


            self.cards.refreshCard(cardID: 3) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [3])

                        do {
                            let fetchedCards = try context.fetch(fetchRequest)

                            XCTAssertEqual(fetchedCards.first?.cardID, 3)
                        } catch {
                            XCTFail(error.localizedDescription)
                        }
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testRefreshCardByIDFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_card_by_id", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)


            self.cards.refreshCard(cardID: 3) { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is APIError)
                        if let error = error as? APIError {
                            XCTAssertEqual(error.statusCode, 404)
                        }
                    case .success:
                        XCTFail("Data response is invalid")
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testUpdateCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_card_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 3

                try? managedObjectContext.save()

                self.cards.updateCard(cardID: 3, status: .locked, nickName: "Transaction card") { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.database.viewContext

                            let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [3])

                            do {
                                let fetchedMessages = try context.fetch(fetchRequest)

                                XCTAssertEqual(fetchedMessages.first?.cardID, 3)
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
    
    func testUpdateCardFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_card_by_id", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 3

                try? managedObjectContext.save()

                self.cards.updateCard(cardID: 3, status: .locked, nickName: "Transaction card") { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateCardEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_card_by_id", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        service = invalidService(keychain: keychain)
        cards = Cards(database: database, service: service, aggregation: aggregation)

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 3

                try? managedObjectContext.save()

                self.cards.updateCard(cardID: 3, status: .locked, nickName: "Transaction card") { (result) in
                    switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is DataError)
                        if let error = error as? DataError {
                            XCTAssertEqual(error.type, DataError.DataErrorType.api)
                            XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                        }
                    case .success:
                        XCTFail("Invalid service throw Error when encoding")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testGetCardPublicKey() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.publicKey.path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_public_key", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()

                try? managedObjectContext.save()

                self.cards.getPublicKey { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            break
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testGetCardPublicKeyFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.publicKey.path) && isMethodGET()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "get_public_key", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()

                try? managedObjectContext.save()

                self.cards.getPublicKey { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testSetCardPin() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.setPin(cardID: 1).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "set_card_pin", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 1

                try? managedObjectContext.save()

                self.cards.setCardPin(cardID: 1, encryptedPIN: "100110 111010 001011 101001", keyID: "d79fe9eb-66dc-4929-bbe8-954d55222e15") { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.database.viewContext

                            let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [1])

                            do {
                                let fetchedMessages = try context.fetch(fetchRequest)

                                XCTAssertEqual(fetchedMessages.first?.cardID, 1)
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
    
    func testSetCardPinFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.setPin(cardID: 1).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "set_card_pin", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 1

                try? managedObjectContext.save()

                self.cards.setCardPin(cardID: 1, encryptedPIN: "100110 111010 001011 101001", keyID: "d79fe9eb-66dc-4929-bbe8-954d55222e15") { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testSetCardPinEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.setPin(cardID: 1).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "set_card_pin", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        service = invalidService(keychain: keychain)
        cards = Cards(database: database, service: service, aggregation: aggregation)

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 1

                try? managedObjectContext.save()

                self.cards.setCardPin(cardID: 1, encryptedPIN: "100110 111010 001011 101001", keyID: "d79fe9eb-66dc-4929-bbe8-954d55222e15") { (result) in
                    switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is DataError)
                        if let error = error as? DataError {
                            XCTAssertEqual(error.type, DataError.DataErrorType.api)
                            XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                        }
                    case .success:
                        XCTFail("Invalid service throw Error when encoding")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testActivateCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.activate(cardID: 2).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "activate_card", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 2
                card.cardStatus = .pending

                try? managedObjectContext.save()

                self.cards.activateCard(cardID: 2, panLastFourDigits: "1234") { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.database.viewContext

                            let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [2])

                            do {
                                let fetchedMessages = try context.fetch(fetchRequest)

                                XCTAssertEqual(fetchedMessages.first?.cardID, 2)
                                XCTAssertEqual(fetchedMessages.first?.cardStatus, .active)
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
    
    func testActivateCardFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.activate(cardID: 2).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "activate_card", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 2
                card.cardStatus = .pending

                try? managedObjectContext.save()

                self.cards.activateCard(cardID: 2, panLastFourDigits: "1234") { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testActivateCardEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.activate(cardID: 2).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "activate_card", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        service = invalidService(keychain: keychain)
        cards = Cards(database: database, service: service, aggregation: aggregation)

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 2
                card.cardStatus = .pending

                try? managedObjectContext.save()

                self.cards.activateCard(cardID: 2, panLastFourDigits: "1234") { (result) in
                    switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is DataError)
                        if let error = error as? DataError {
                            XCTAssertEqual(error.type, DataError.DataErrorType.api)
                            XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                        }
                    case .success:
                        XCTFail("Invalid service throw Error when encoding")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testLockCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.lock(cardID: 4).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "lock_card", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 4
                card.cardStatus = .active

                try? managedObjectContext.save()

                self.cards.lockCard(cardID: 4) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.database.viewContext

                            let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [4])

                            do {
                                let fetchedMessages = try context.fetch(fetchRequest)

                                XCTAssertEqual(fetchedMessages.first?.cardID, 4)
                                XCTAssertEqual(fetchedMessages.first?.cardStatus, .locked)
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
    
    func testLockCardFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.lock(cardID: 4).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "lock_card", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 4
                card.cardStatus = .active

                try? managedObjectContext.save()

                self.cards.lockCard(cardID: 4) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testLockCardEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.lock(cardID: 4).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "lock_card", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        service = invalidService(keychain: keychain)
        cards = Cards(database: database, service: service, aggregation: aggregation)

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 4
                card.cardStatus = .active

                try? managedObjectContext.save()

                self.cards.lockCard(cardID: 4) { (result) in
                    switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is DataError)
                        if let error = error as? DataError {
                            XCTAssertEqual(error.type, DataError.DataErrorType.api)
                            XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                        }
                    case .success:
                        XCTFail("Invalid service throw Error when encoding")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testUnlockCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.unlock(cardID: 5).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "unlock_card", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 5
                card.cardStatus = .locked

                try? managedObjectContext.save()

                self.cards.unlockCard(cardID: 5) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            let context = self.database.viewContext

                            let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [5])

                            do {
                                let fetchedMessages = try context.fetch(fetchRequest)

                                XCTAssertEqual(fetchedMessages.first?.cardID, 5)
                                XCTAssertEqual(fetchedMessages.first?.cardStatus, .active)
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
    
    func testUnlockCardFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.unlock(cardID: 5).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "unlock_card", ofType: "json")!, status: 404, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 5
                card.cardStatus = .locked

                try? managedObjectContext.save()

                self.cards.unlockCard(cardID: 5) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }


    func testReplaceCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.replace(cardID: 6).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 6

                try? managedObjectContext.save()

                self.cards.replaceCard(cardID: 6, reason: .loss) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTFail(error.localizedDescription)
                        case .success:
                            break
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testReplaceCardFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.replace(cardID: 6).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 6

                try? managedObjectContext.save()

                self.cards.replaceCard(cardID: 6, reason: .loss) { (result) in
                    switch result {
                        case .failure(let error):
                            XCTAssertTrue(error is APIError)
                            if let error = error as? APIError {
                                XCTAssertEqual(error.statusCode, 404)
                            }
                        case .success:
                            XCTFail("Data response is invalid")
                    }

                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testReplaceCardEncodeFail() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.replace(cardID: 6).path) && isMethodPUT()) { (request) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        service = invalidService(keychain: keychain)
        cards = Cards(database: database, service: service, aggregation: aggregation)

        database.setup { (error) in
            XCTAssertNil(error)

            let managedObjectContext = self.database.newBackgroundContext()

            managedObjectContext.performAndWait {
                let card = Card(context: managedObjectContext)
                card.populateTestData()
                card.cardID = 6

                try? managedObjectContext.save()

                self.cards.replaceCard(cardID: 6, reason: .loss) { (result) in
                    switch result {
                    case .failure(let error):
                        XCTAssertTrue(error is DataError)
                        if let error = error as? DataError {
                            XCTAssertEqual(error.type, DataError.DataErrorType.api)
                            XCTAssertEqual(error.subType, DataError.DataErrorSubType.invalidData)
                        }
                    case .success:
                        XCTFail("Invalid service throw Error when encoding")
                    }
                    
                    expectation1.fulfill()
                }
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }


    func testCardsLinkToAccounts() {
        let expectation1 = expectation(description: "Database Setup")
        let expectation2 = expectation(description: "Network Accounts Request")
        let expectation3 = expectation(description: "Network Cards Request")

        connect(endpoint: AggregationEndpoint.accounts.path.prefixedWithSlash, toResourceWithName: "accounts_valid")
        connect(endpoint: CardsEndpoint.cards.path.prefixedWithSlash, toResourceWithName: "get_cards")

        database.setup { (error) in
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

        cards.refreshCards { result in
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

        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [123])

        do {
            let fetchedCards = try context.fetch(fetchRequest)

            XCTAssertEqual(fetchedCards.count, 1)

            if let card = fetchedCards.first {
                XCTAssertNotNil(card.accountID)

                XCTAssertEqual(card.accountID, card.account?.accountID)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }

        HTTPStubs.removeAllStubs()

    }
}
