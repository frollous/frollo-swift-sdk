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

class APIMessageResponseTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() {
        let messageResponse = APIMessageResponse.testCompleteData()
        
        let encoder = JSONEncoder()
        
        do {
            let encodedMessage = try encoder.encode(messageResponse)
            
            let encodedMessageString = String(data: encodedMessage, encoding: .utf8)
            
            if let message = encodedMessageString {
                XCTAssertTrue(message.contains("\"id\":" +  String(messageResponse.id)))
            } else {
                XCTFail("Empty String")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
