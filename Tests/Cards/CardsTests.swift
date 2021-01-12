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
@testable import FrolloSDK

class CardsTests: BaseTestCase {

    var aggregation: Aggregation!
    var cards: Cards!

    override func setUp() {
        testsKeychainService = "CardsTests"
        super.setUp()

        let keychain = defaultKeychain(isNetwork: true)

        let authentication = defaultAuthentication(keychain: keychain)
        let network = defaultNetwork(keychain: keychain, authentication: authentication)
        let service = defaultService(keychain: keychain, authentication: authentication)
        let authService = defaultAuthService(keychain: keychain, network: network)

        let oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: config.clientID, redirectURL: FrolloSDKConfiguration.redirectURL, serverURL: config.serverEndpoint, authService: authService, preferences: preferences, delegate: nil)
        oAuth2Authentication.loggedIn = true
        aggregation = Aggregation(database: database, service: service)

        cards = Cards(database: database, service: service, aggregation: aggregation)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    func testCreateCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.cards.path) && isMethodPOST()) { (request) -> OHHTTPStubsResponse in
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
        OHHTTPStubs.removeAllStubs()
    }

    func testRefreshCards() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.cards.path) && isMethodGET()) { (request) -> OHHTTPStubsResponse in
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

    func testRefreshCardByID() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodGET()) { (request) -> OHHTTPStubsResponse in
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

    func testUpdateCard() {
        let expectation1 = expectation(description: "Network Request 1")

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + CardsEndpoint.card(cardID: 3).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
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

        OHHTTPStubs.removeAllStubs()

    }
}
