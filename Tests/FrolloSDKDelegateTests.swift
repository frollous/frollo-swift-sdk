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

class FrolloSDKDelegateTests: XCTestCase, FrolloSDKDelegate {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSettingDelegateUpdatesModules() {
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = FrolloSDK()
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    sdk.delegate = self
                    
                    XCTAssertTrue(sdk.messages.delegate === self)
                    XCTAssertTrue(sdk.events.delegate === self)
            }
        }
    }
    
    func testSettingDelegateBeforeSetup() {
        let config = FrolloSDKConfiguration.testConfig()
        let sdk = FrolloSDK()
        
        sdk.delegate = self
        
        sdk.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertTrue(sdk.messages.delegate === self)
                    XCTAssertTrue(sdk.events.delegate === self)
            }
        }
    }
    
    func messageReceived(_ messageID: Int64) {
        // Stub
    }
    
    func eventTriggered(eventName: String) {
        // Stub
    }

}
