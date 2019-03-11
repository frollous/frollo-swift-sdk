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

class PreferencesTests: XCTestCase {
    
    let keychainService = "PreferencesTestsKeychain"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        Keychain(service: keychainService).removeAll()
    }
    
    func testFeatureFlags() {
        let path = tempFolderPath()
        
        let database = Database(path: path)
        
        let preferences = Preferences(path: path)
        
        let managedObjectContext = database.viewContext
        
        let user = User(context: managedObjectContext)
        user.populateTestData()
        
        user.features = [User.FeatureFlag(enabled: false, feature: "aggregation")]
        
        preferences.refreshFeatures(user: user)
        
        XCTAssertFalse(preferences.featureAggregation)
    }
    
    func testResetPreferences() {
        //let preferences = Preferences()
    }
    
}
