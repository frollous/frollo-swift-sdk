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

class ChallengeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingChallenge() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let challengeResponse = APIChallengeResponse.testCompleteData()
            
            let challenge = Challenge(context: managedObjectContext)
            challenge.update(response: challengeResponse, context: managedObjectContext)
            
            XCTAssertEqual(challengeResponse.id, challenge.challengeID)
            XCTAssertEqual(challengeResponse.community.activeCount, challenge.activeCount)
            XCTAssertEqual(challengeResponse.community.averageSavingAmount, challenge.averageSavingAmount.int64Value)
            XCTAssertEqual(challengeResponse.community.completedCount, challenge.completedCount)
            XCTAssertEqual(challengeResponse.community.startedCount, challenge.startedCount)
            XCTAssertEqual(challengeResponse.challengeType, challenge.challengeType)
            XCTAssertEqual(challengeResponse.description, challenge.details)
            XCTAssertEqual(challengeResponse.frequency, challenge.frequency)
            XCTAssertEqual(challengeResponse.largeLogoURL, challenge.largeLogoURLString)
            XCTAssertEqual(challengeResponse.name, challenge.name)
            XCTAssertEqual(challengeResponse.smallLogoURL, challenge.smallLogoURLString)
            XCTAssertEqual(challengeResponse.source, challenge.source)
            XCTAssertEqual(challengeResponse.steps, challenge.steps)
        }
    }

}
