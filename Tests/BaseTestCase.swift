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

class BaseTestCase: XCTestCase, DatabaseIdentifying, KeychainServiceIdentifying {
    
    var testsKeychainService: String?
    
    var keychainService: String {
        return testsKeychainService!
    }

    var testsDatabase: Database?
    
    var database: Database {
        return testsDatabase!
    }
    
    override func setUp() {
        super.setUp()
        testsDatabase = Database(path: tempFolderPath())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }

}
