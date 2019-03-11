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

import XCTest
@testable import FrolloSDK

class AccountBalanceTierTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingBalanceTier() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let accountBalanceTierResponse = APIAccountResponse.BalanceTier(description: UUID().uuidString,
                                                                            min: Int64(arc4random()),
                                                                            max: Int64(arc4random()))
            
            let accountBalanceTier = AccountBalanceTier(context: managedObjectContext)
            accountBalanceTier.update(response: accountBalanceTierResponse)
            
            XCTAssertEqual(accountBalanceTier.name, accountBalanceTierResponse.description)
            XCTAssertEqual(accountBalanceTier.maximum, Decimal(accountBalanceTierResponse.max) as NSDecimalNumber?)
            XCTAssertEqual(accountBalanceTier.minimum, Decimal(accountBalanceTierResponse.min) as NSDecimalNumber?)
        }
    }
    
}
