//
//  Copyright © 2018 Frollo. All rights reserved.
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

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class ChallengesRequestTests: XCTestCase {
    
    private let keychainService = "ChallengesRequestTests"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
    }

    // MARK: - Challenges Tests
    
    func testFetchChallenges() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.challenges.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "challenges_valid", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchChallenges { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 9)
                    
                    if let firstChallenge = response.first {
                        XCTAssertEqual(firstChallenge.id, 24)
                        XCTAssertEqual(firstChallenge.community.activeCount, 1)
                        XCTAssertEqual(firstChallenge.community.averageSavingAmount, 89)
                        XCTAssertEqual(firstChallenge.community.completedCount, 2)
                        XCTAssertEqual(firstChallenge.community.startedCount, 12)
                        XCTAssertEqual(firstChallenge.description, "Investigate your telecoms packages. You can even use our bill finding feature and see how much you spend each month.\r\n\r\nShop around or ask yourself the hard question, can I do without cable TV?")
                        XCTAssertEqual(firstChallenge.challengeType, .transactionCategory)
                        XCTAssertEqual(firstChallenge.frequency, .monthly)
                        XCTAssertEqual(firstChallenge.largeLogoURL, "https://frollo-sandbox.s3.amazonaws.com/challenges/24/large/app/1492485917.png?1492485917")
                        XCTAssertEqual(firstChallenge.name, "Telco savings")
                        XCTAssertEqual(firstChallenge.smallLogoURL, "https://frollo-sandbox.s3.amazonaws.com/challenges/24/small/app/1492485916.png?1492485916")
                        XCTAssertEqual(firstChallenge.source, .suggested)
                        XCTAssertEqual(firstChallenge.steps, ["Review your mobile bill and see if you are exceeding your data plan.\r", "You could get more data for the same price and reduce your overspend.\r", "Drop some of the packages you have on cable TV.\r", "Find the shows you want on streaming services, you may have to wait but you can still binge watch."])
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchChallengeByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + ChallengesEndpoint.challenge(challengeID: 15).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "challenge_id_15", ofType: "json")!, headers: [HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let networkAuthenticator = NetworkAuthenticator(authorizationEndpoint: config.authorizationEndpoint, serverEndpoint: config.serverEndpoint, tokenEndpoint: config.tokenEndpoint, keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, networkAuthenticator: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        service.fetchChallenge(challengeID: 15) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 15)
                    XCTAssertEqual(response.community.activeCount, 6)
                    XCTAssertEqual(response.community.averageSavingAmount, 140)
                    XCTAssertEqual(response.community.completedCount, 9)
                    XCTAssertEqual(response.community.startedCount, 31)
                    XCTAssertEqual(response.description, "This challenge involves reducing the number of times you go to the ATM.\r\n\r\nYou must also withdraw only $50 per person in your household per week.\r\n\r\nIf paying for something on plastic costs more than by paying in cash (eg less than $10 take the smart choice and pay in cash and save money)")
                    XCTAssertEqual(response.challengeType, .transactionCategory)
                    XCTAssertEqual(response.frequency, .monthly)
                    XCTAssertEqual(response.largeLogoURL, "https://frollo-sandbox.s3.amazonaws.com/challenges/15/large/app/1491915909.png?1491915909")
                    XCTAssertEqual(response.name, "Plastic vs Cash")
                    XCTAssertEqual(response.smallLogoURL, "https://frollo-sandbox.s3.amazonaws.com/challenges/15/small/app/1491915908.png?1491915908")
                    XCTAssertEqual(response.source, .suggested)
                    XCTAssertEqual(response.steps, ["Visit the ATM at the beginning of the month and withdraw the absolute minimum you may require.\r", "Safely store some cash at home to reduce the temptation.\r", "Create a new habit of using plastic and discover where your money goes.\r", "Tap responsibly!"])
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

}
