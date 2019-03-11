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

class ProviderAccountTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingProviderAccount() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let providerAccountResponse = APIProviderAccountResponse.testCompleteDate()
            
            let providerAccount = ProviderAccount(context: managedObjectContext)
            providerAccount.update(response: providerAccountResponse, context: managedObjectContext)
            
            XCTAssertEqual(providerAccount.providerAccountID, providerAccountResponse.id)
            XCTAssertEqual(providerAccount.providerID, providerAccountResponse.providerID)
            XCTAssertEqual(providerAccount.editable, providerAccountResponse.editable)
            XCTAssertEqual(providerAccount.nextRefresh, providerAccountResponse.refreshStatus.nextRefresh)
            XCTAssertEqual(providerAccount.lastRefreshed, providerAccountResponse.refreshStatus.lastRefreshed)
            XCTAssertEqual(providerAccount.refreshStatus, providerAccountResponse.refreshStatus.status)
            XCTAssertEqual(providerAccount.refreshSubStatus, providerAccountResponse.refreshStatus.subStatus)
            XCTAssertEqual(providerAccount.refreshAdditionalStatus, providerAccountResponse.refreshStatus.additionalStatus)
            XCTAssertEqual(providerAccount.loginForm?.id, providerAccountResponse.loginForm?.id)
            XCTAssertNotNil(providerAccount.loginForm)
        }
    }
    
}
