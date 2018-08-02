//
//  AggregationRequestTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

import OHHTTPStubs

class AggregationRequestTests: XCTestCase {
    
    private let keychainService = "AggregationRequestTests"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        Keychain(service: keychainService).removeAll()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchProviders() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviders { (response, error) in
            XCTAssertNil(error)
            
            if let providersResponse = response {
                XCTAssertEqual(providersResponse.count, 311)
                
                if let firstProvider = providersResponse.first {
                    XCTAssertEqual(firstProvider.id, 447)
                    XCTAssertEqual(firstProvider.name, "PayPal")
                    XCTAssertEqual(firstProvider.smallLogoURLString, "https://example.com/small_logo.png")
                    XCTAssertEqual(firstProvider.status, .supported)
                    XCTAssertEqual(firstProvider.popular, false)
                    XCTAssertEqual(firstProvider.containerNames, [.bank, .creditCard])
                    XCTAssertEqual(firstProvider.loginURLString, "https://www.paypal.com/signin/")
                    XCTAssertNil(firstProvider.authType)
                    XCTAssertNil(firstProvider.encryption)
                    XCTAssertNil(firstProvider.forgotPasswordURLString)
                    XCTAssertNil(firstProvider.largeLogoURLString)
                    XCTAssertNil(firstProvider.helpMessage)
                    XCTAssertNil(firstProvider.loginHelpMessage)
                    XCTAssertNil(firstProvider.mfaType)
                    XCTAssertNil(firstProvider.oAuthSite)
                    XCTAssertNil(firstProvider.encryption)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchProvidersSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviders { (response, error) in
            XCTAssertNil(error)
            
            if let providersResponse = response {
                XCTAssertEqual(providersResponse.count, 309)
                
                if let firstProvider = providersResponse.first {
                    XCTAssertEqual(firstProvider.id, 447)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchProviderByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.provider(providerID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProvider(providerID: 12345) { (response, error) in
            XCTAssertNil(error)
            
            if let providerResponse = response {
                XCTAssertEqual(providerResponse.id, 12345)
                XCTAssertEqual(providerResponse.name, "AustralianSuper")
                XCTAssertEqual(providerResponse.smallLogoURLString, "https://example.com/australiansuper-small.png")
                XCTAssertEqual(providerResponse.status, .disabled)
                XCTAssertEqual(providerResponse.popular, false)
                XCTAssertEqual(providerResponse.containerNames, [.investment, .insurance])
                XCTAssertEqual(providerResponse.loginURLString, "https://www.australiansuper.com/login.aspx")
                XCTAssertEqual(providerResponse.authType, .mfaCredentials)
                XCTAssertEqual(providerResponse.encryption?.encryptionType, .encryptValues)
                XCTAssertEqual(providerResponse.encryption?.alias, "09282016_1")
                XCTAssertEqual(providerResponse.encryption?.pem, "-----BEGIN PUBLIC KEY----------END PUBLIC KEY-----")
                XCTAssertEqual(providerResponse.forgotPasswordURLString, "https://www.australiansuper.com/forgotpassword.aspx")
                XCTAssertEqual(providerResponse.helpMessage, "test")
                XCTAssertEqual(providerResponse.largeLogoURLString, "https://example.com/australiansuper-logo600pxw.png")
                XCTAssertEqual(providerResponse.loginHelpMessage, "login here")
                XCTAssertEqual(providerResponse.mfaType, .token)
                XCTAssertEqual(providerResponse.oAuthSite, false)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchProviderAccounts() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviderAccounts { (response, error) in
            XCTAssertNil(error)
            
            if let providerAccountsResponse = response {
                XCTAssertEqual(providerAccountsResponse.count, 4)
                
                if let firstProviderAccount = providerAccountsResponse.first {
                    XCTAssertEqual(firstProviderAccount.id, 623)
                    XCTAssertEqual(firstProviderAccount.providerID, 11582)
                    XCTAssertEqual(firstProviderAccount.editable, true)
                    XCTAssertEqual(firstProviderAccount.refreshStatus.status, .success)
                    XCTAssertEqual(firstProviderAccount.refreshStatus.subStatus, .success)
                    XCTAssertEqual(firstProviderAccount.refreshStatus.lastRefreshed, Date(timeIntervalSince1970: 1533174026))
                    XCTAssertNil(firstProviderAccount.refreshStatus.nextRefresh)
                    XCTAssertNil(firstProviderAccount.refreshStatus.additionalStatus)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchProviderAccountsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviderAccounts { (response, error) in
            XCTAssertNil(error)
            
            if let providerAccountsResponse = response {
                XCTAssertEqual(providerAccountsResponse.count, 2)
                
                if let firstProviderAccount = providerAccountsResponse.first {
                    XCTAssertEqual(firstProviderAccount.id, 624)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    
    
}
