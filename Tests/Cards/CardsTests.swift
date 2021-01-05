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

            self.cards.createCard(accountID: 325, firstName: "Jacob", lastName: "Smith", postalAddressLine1: "Address Line 1", postalAddressLine2: "Address Line 2", postalAddressSuburb: "Mock Suburb", postalCode: "123456", postalAddressState: "NSW", postalAddressCountry: "Australia") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        let context = self.database.viewContext

                        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "cardID == %ld", argumentArray: [2])

                        do {
                            let fetchedGoals = try context.fetch(fetchRequest)

                            XCTAssertEqual(fetchedGoals.first?.cardID, 2)
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
}
