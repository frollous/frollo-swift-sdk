//
//  NetworkErrorTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 9/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
