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
    
    func testFetchProviderAccountByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 123).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviderAccount(providerAccountID: 123) { (response, error) in
            XCTAssertNil(error)
            
            if let providerAccountResponse = response {
                XCTAssertEqual(providerAccountResponse.id, 123)
                XCTAssertEqual(providerAccountResponse.providerID, 4078)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchAccounts() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchAccounts { (response, error) in
            XCTAssertNil(error)
            
            if let accountsResponse = response {
                XCTAssertEqual(accountsResponse.count, 4)
                
                if let firstAccount = accountsResponse.first {
                    XCTAssertEqual(firstAccount.id, 542)
                    XCTAssertEqual(firstAccount.providerAccountID, 867)
                    XCTAssertEqual(firstAccount.refreshStatus.status, .success)
                    XCTAssertEqual(firstAccount.refreshStatus.subStatus, .success)
                    XCTAssertEqual(firstAccount.refreshStatus.lastRefreshed, Date(timeIntervalSince1970: 1533174026))
                    XCTAssertNil(firstAccount.refreshStatus.nextRefresh)
                    XCTAssertNil(firstAccount.refreshStatus.additionalStatus)
                    XCTAssertEqual(firstAccount.availableCash?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.availableCash?.currency, "AUD")
                    XCTAssertEqual(firstAccount.currentBalance?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.currentBalance?.currency, "AUD")
                    XCTAssertEqual(firstAccount.availableBalance?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.availableBalance?.currency, "AUD")
                    XCTAssertEqual(firstAccount.availableCredit?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.availableCredit?.currency, "AUD")
                    XCTAssertEqual(firstAccount.totalCashLimit?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.totalCashLimit?.currency, "AUD")
                    XCTAssertEqual(firstAccount.totalCreditLine?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.totalCreditLine?.currency, "AUD")
                    XCTAssertEqual(firstAccount.amountDue?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.amountDue?.currency, "AUD")
                    XCTAssertEqual(firstAccount.minimumAmountDue?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.minimumAmountDue?.currency, "AUD")
                    XCTAssertEqual(firstAccount.lastPaymentAmount?.amount, "1823.85")
                    XCTAssertEqual(firstAccount.lastPaymentAmount?.currency, "AUD")
                    XCTAssertEqual(firstAccount.apr, "18.99")
                    XCTAssertEqual(firstAccount.interestRate, "3.01")
                    XCTAssertEqual(firstAccount.holderProfile?.name, "Jacob")
                    XCTAssertEqual(firstAccount.container, .bank)
                    XCTAssertEqual(firstAccount.accountType, .checking)
                    XCTAssertEqual(firstAccount.included, true)
                    XCTAssertEqual(firstAccount.hidden, false)
                    XCTAssertEqual(firstAccount.favourite, true)
                    XCTAssertEqual(firstAccount.accountName, "Personal Account")
                    XCTAssertEqual(firstAccount.providerName, "ME Bank (demo)")
                    XCTAssertEqual(firstAccount.balanceDetails?.tiers.first?.description, "Below average")
                    XCTAssertEqual(firstAccount.balanceDetails?.tiers.first?.max, 549)
                    XCTAssertEqual(firstAccount.balanceDetails?.tiers.first?.min, 0)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchAccountsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchAccounts { (response, error) in
            XCTAssertNil(error)
            
            if let accountsResponse = response {
                XCTAssertEqual(accountsResponse.count, 2)
                
                if let firstAccount = accountsResponse.first {
                    XCTAssertEqual(firstAccount.id, 542)
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchAccountByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchAccount(accountID: 542) { (response, error) in
            XCTAssertNil(error)
            
            if let accountResponse = response {
                XCTAssertEqual(accountResponse.id, 542)
                XCTAssertEqual(accountResponse.providerAccountID, 867)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateAccountValid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APIAccountUpdateRequest.testUpdateDataValid()
        network.updateAccount(accountID: 542, request: request) { (response, error) in
            XCTAssertNil(error)
            
            if let accountResponse = response {
                XCTAssertEqual(accountResponse.id, 542)
                XCTAssertEqual(accountResponse.providerAccountID, 867)
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testUpdateAccountInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APIAccountUpdateRequest.testUpdateDataInvalid()
        network.updateAccount(accountID: 542, request: request) { (response, error) in
            XCTAssertNotNil(error)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchTransactionCategories() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransactionCategories() { (response, error) in
            XCTAssertNil(error)
            
            if let categoriesResponse = response {
                XCTAssertEqual(categoriesResponse.count, 43)
                
                if let firstCategory = categoriesResponse.first {
                    XCTAssertEqual(firstCategory.id, 60)
                    
                }
            } else {
                XCTFail("No response object")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testFetchTransactionCategoriesSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransactionCategories() { (response, error) in
            XCTAssertNil(error)
            
            if let categoriesResponse = response {
                XCTAssertEqual(categoriesResponse.count, 40)
                
                if let firstCategory = categoriesResponse.first {
                    XCTAssertEqual(firstCategory.id, 60)
                    
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
