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

class PayDayTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingPayDay() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let payDayResponse = APIPayDayResponse.testCompleteData()
            
            let payDay = PayDay(context: managedObjectContext)
            payDay.update(response: payDayResponse)
            
            XCTAssertEqual(payDayResponse.lastTransactionDate, payDay.lastDateString)
            XCTAssertEqual(payDayResponse.nextTransactionDate, payDay.nextDateString)
            XCTAssertEqual(payDayResponse.frequency, payDay.period)
            XCTAssertEqual(payDayResponse.status, payDay.status)
        }
    }

}
