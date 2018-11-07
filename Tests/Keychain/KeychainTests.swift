//
//  KeychainTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class KeychainTests: XCTestCase {
    
    let serviceName = "TestKeychain"
    
    override func setUp() {
        super.setUp()
        
        Keychain(service: serviceName).removeAll()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Keychain(service: serviceName).removeAll()
    }
    
    // MARK - Keychain Updating Tests
    
    func testKeychainAddItems() {
        let keychain = Keychain(service: serviceName)
        
        let testKey1 = "TestKey1"
        let testKey2 = "TestKey2"
        let testToken1 = "TestToken1"
        let testToken2 = "TestToken2"
        
        keychain.set(key: testKey1, value: testToken1)
        keychain.set(key: testKey2, value: testToken2)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken1)
        XCTAssertEqual(keychain.get(key: testKey2), testToken2)
        XCTAssertNil(keychain.get(key: "FakeKey"))
        
        keychain.removeAll()
    }
    
    func testKeychainUpdateItem() {
        let keychain = Keychain(service: serviceName)
        
        let testKey1 = "TestKey1"
        let testToken1 = "TestToken1"
        let testToken2 = "TestToken2"
        
        keychain.set(key: testKey1, value: testToken1)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken1)
        
        keychain.set(key: testKey1, value: testToken2)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken2)
        
        keychain.removeAll()
    }
    
    func testKeychainRemoveItem() {
        let keychain = Keychain(service: serviceName)
        
        let testKey1 = "TestKey1"
        let testToken1 = "TestToken1"
        
        keychain.set(key: testKey1, value: testToken1)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken1)
        
        keychain.remove(key: testKey1)
        
        XCTAssertNil(keychain.get(key: testKey1))
        
        keychain.removeAll()
    }
    
    func testKeychainRemoveAllItems() {
        let keychain = Keychain(service: serviceName)
        
        let testKey1 = "TestKey1"
        let testKey2 = "TestKey2"
        let testToken1 = "TestToken1"
        let testToken2 = "TestToken2"
        
        keychain.set(key: testKey1, value: testToken1)
        keychain.set(key: testKey2, value: testToken2)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken1)
        XCTAssertEqual(keychain.get(key: testKey2), testToken2)
        
        keychain.removeAll()
        
        XCTAssertNil(keychain.get(key: testKey1))
        XCTAssertNil(keychain.get(key: testKey2))
    }
    
    // MARK: - Keychain initialisation tests
    
    func testKeychainAccessibilityInit() {
        let keychain = Keychain(service: serviceName, accessibility: .whenUnlocked)
        
        let testKey1 = "TestKey1"
        let testToken1 = "TestToken1"
        
        keychain.set(key: testKey1, value: testToken1)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken1)
        
        keychain.removeAll()
        
        XCTAssertNil(keychain.get(key: testKey1))
    }
    
    @available(macOS, unavailable)
    func testKeychainAccessGroupInit() {
        #if os(iOS)
        let accessGroup = "MFREL6LQ6B.us.frollo.FrolloSDK"
        #elseif os(tvOS)
        let accessGroup = "MFREL6LQ6B.us.frollo.FrolloSDK"
        #else
        let accessGroup = "invalid"
        #endif
        
        let keychain = Keychain(service: serviceName, accessGroup: accessGroup)
        
        let testKey1 = "TestKey1"
        let testToken1 = "TestToken1"
        
        keychain.set(key: testKey1, value: testToken1)
        
        XCTAssertEqual(keychain.get(key: testKey1), testToken1)
        
        keychain.removeAll()
        
        XCTAssertNil(keychain.get(key: testKey1))
    }
    
    // MARK: - Subscript Tests
    
    func testKeychainSubscript() {
        let keychain = Keychain(service: serviceName)
        
        let testKey1 = "TestKey1"
        let testToken1 = "TestToken1"
        
        keychain[testKey1] = testToken1
        
        XCTAssertEqual(keychain[testKey1], testToken1)
        
        keychain[testKey1] = nil
        
        XCTAssertNil(keychain[testKey1])
    }
    
}
