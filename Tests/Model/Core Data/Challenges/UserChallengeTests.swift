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

class UserChallengeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingUserChallenge() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let userChallengeResponse = APIUserChallengeResponse.testCompleteData()
            
            let userChallenge = UserChallenge(context: managedObjectContext)
            userChallenge.update(response: userChallengeResponse, context: managedObjectContext)
            
            XCTAssertEqual(userChallengeResponse.id, userChallenge.userChallengeID)
            XCTAssertEqual(userChallengeResponse.challengeID, userChallenge.challengeID)
            XCTAssertEqual(userChallengeResponse.currency, userChallenge.currency)
            XCTAssertEqual(userChallengeResponse.currentSpendAmount, userChallenge.currentSpendAmount.int64Value)
            XCTAssertEqual(userChallengeResponse.endDate, userChallenge.endDateString)
            XCTAssertEqual(userChallengeResponse.previousAmount, userChallenge.previousAmount.int64Value)
            XCTAssertEqual(userChallengeResponse.startDate, userChallenge.startDateString)
            XCTAssertEqual(userChallengeResponse.status, userChallenge.status)
            XCTAssertEqual(userChallengeResponse.targetAmount, userChallenge.targetAmount.int64Value)
        }
    }

}
