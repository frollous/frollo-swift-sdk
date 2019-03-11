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

class NetworkErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNetworkErrorConnectionFailure() {
        let systemError = NSError(domain: NSURLErrorDomain, code: -999, userInfo: [NSURLErrorFailingURLStringErrorKey: "https://example.com", NSLocalizedDescriptionKey: "cancelled", NSURLErrorFailingURLErrorKey: URL(string: "https://example.com")!])
        
        let networkError = NetworkError(error: systemError)
        XCTAssertEqual(networkError.type, .connectionFailure)
        XCTAssertEqual(networkError.systemError, systemError)
        XCTAssertEqual(networkError.localizedDescription, Localization.string("Error.Network.ConnectionFailure"))
        XCTAssertGreaterThan(networkError.debugDescription.count, networkError.localizedDescription.count)
    }
    
    func testNetworkErrorInvalidSSL() {
        let systemError = NSError(domain: NSStreamSocketSSLErrorDomain, code: -999, userInfo: [NSURLErrorFailingURLStringErrorKey: "https://example.com", NSLocalizedDescriptionKey: "cancelled", NSURLErrorFailingURLErrorKey: URL(string: "https://example.com")!])
        
        let networkError = NetworkError(error: systemError)
        XCTAssertEqual(networkError.type, .invalidSSL)
        XCTAssertEqual(networkError.systemError, systemError)
        XCTAssertEqual(networkError.localizedDescription, Localization.string("Error.Network.InvalidSSL"))
        XCTAssertGreaterThan(networkError.debugDescription.count, networkError.localizedDescription.count)
    }
    
    func testNetworkErrorUnknown() {
        let systemError = NSError(domain: NSMachErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "some unexpected NSError"])
        
        let networkError = NetworkError(error: systemError)
        XCTAssertEqual(networkError.type, .unknown)
        XCTAssertEqual(networkError.systemError, systemError)
        XCTAssertEqual(networkError.localizedDescription, Localization.string("Error.Network.UnknownError"))
        XCTAssertGreaterThan(networkError.debugDescription.count, networkError.localizedDescription.count)
    }
    
}
