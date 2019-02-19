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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviders { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 311)
                    
                    if let firstProvider = response.first {
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
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProvidersSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providers.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "providers_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviders { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 309)
                    
                    if let firstProvider = response.first {
                        XCTAssertEqual(firstProvider.id, 447)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.provider(providerID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_id_12345", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProvider(providerID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let providerResponse):
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
                    XCTAssertEqual(providerResponse.encryption?.pem, "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1eXKHvPBlS4A41OvQqFn0SfNH7OgEs2MXMLeyp3xKorEipEKuzv/JDtHFHRAfYwyeiC0q+me0R8GLA6NEDGDfpxGv/XUFyza609ZqtCTOiGCp8DcjLG0mPljdGA1Df0BKhF3y5uata1y0dKSI8aY8lXPza+Tsw4TtjdmHbJ2rR3sFZkYch1RTmNKxKDxMgUmtIk785lIfLJ2x6lvh4ZS9QhuAnsoVM91WWKHrLHYfAeA/zD1TxHDm5/4wPbmFLEBe2+5zGae19nsA/9zDwKP4whpte9HuDDQa5Vsq+aWj5pDJuvFgwA/DStqcHGijn5gzB/JXEoE9qx+dcG92PpvfwIDAQAB\n-----END PUBLIC KEY-----")
                    XCTAssertEqual(providerResponse.forgotPasswordURLString, "https://www.australiansuper.com/forgotpassword.aspx")
                    XCTAssertEqual(providerResponse.helpMessage, "test")
                    XCTAssertEqual(providerResponse.largeLogoURLString, "https://example.com/australiansuper-logo600pxw.png")
                    XCTAssertEqual(providerResponse.loginHelpMessage, "login here")
                    XCTAssertEqual(providerResponse.mfaType, .token)
                    XCTAssertEqual(providerResponse.oAuthSite, false)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderAccounts() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 4)
                    
                    if let firstProviderAccount = response.first {
                        XCTAssertEqual(firstProviderAccount.id, 623)
                        XCTAssertEqual(firstProviderAccount.providerID, 11582)
                        XCTAssertEqual(firstProviderAccount.editable, true)
                        XCTAssertEqual(firstProviderAccount.refreshStatus.status, .success)
                        XCTAssertEqual(firstProviderAccount.refreshStatus.subStatus, .success)
                        XCTAssertEqual(firstProviderAccount.refreshStatus.lastRefreshed, Date(timeIntervalSince1970: 1533174026))
                        XCTAssertNil(firstProviderAccount.refreshStatus.nextRefresh)
                        XCTAssertNil(firstProviderAccount.refreshStatus.additionalStatus)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderAccountsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_accounts_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 2)
                    
                    if let firstProviderAccount = response.first {
                        XCTAssertEqual(firstProviderAccount.id, 624)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchProviderAccountByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 123).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchProviderAccount(providerAccountID: 123) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let providerAccountResponse):
                    XCTAssertEqual(providerAccountResponse.id, 123)
                    XCTAssertEqual(providerAccountResponse.providerID, 4078)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testCreateProviderAccount() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "provider_account_id_123", ofType: "json")!, status: 201, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let filledForm = ProviderLoginForm.loginFormFilledData()
        let request = APIProviderAccountCreateRequest(loginForm: filledForm, providerID: 4078)
        
        network.createProviderAccount(request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let providerAccountResponse):
                    XCTAssertEqual(providerAccountResponse.id, 123)
                    XCTAssertEqual(providerAccountResponse.providerID, 4078)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testDeleteProviderAccount() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.providerAccount(providerAccountID: 12345).path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.deleteProviderAccount(providerAccountID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
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
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 4)
                    
                    if let firstAccount = response.first {
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
                        XCTAssertEqual(firstAccount.accountAttributes.container, .bank)
                        XCTAssertEqual(firstAccount.accountAttributes.accountType, .bankAccount)
                        XCTAssertEqual(firstAccount.accountAttributes.classification, .personal)
                        XCTAssertEqual(firstAccount.accountAttributes.group, .bank)
                        XCTAssertEqual(firstAccount.included, true)
                        XCTAssertEqual(firstAccount.hidden, false)
                        XCTAssertEqual(firstAccount.favourite, true)
                        XCTAssertEqual(firstAccount.accountName, "Personal Account")
                        XCTAssertEqual(firstAccount.providerName, "ME Bank (demo)")
                        XCTAssertEqual(firstAccount.balanceDetails?.tiers.first?.description, "Below average")
                        XCTAssertEqual(firstAccount.balanceDetails?.tiers.first?.max, 549)
                        XCTAssertEqual(firstAccount.balanceDetails?.tiers.first?.min, 0)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAccountsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.accounts.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "accounts_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 2)
                    
                    if let firstAccount = response.first {
                        XCTAssertEqual(firstAccount.id, 542)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAccountByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchAccount(accountID: 542) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 542)
                    XCTAssertEqual(response.providerAccountID, 867)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateAccountValid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APIAccountUpdateRequest.testUpdateDataValid()
        network.updateAccount(accountID: 542, request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 542)
                    XCTAssertEqual(response.providerAccountID, 867)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateAccountInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.account(accountID: 542).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "account_id_542", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APIAccountUpdateRequest.testUpdateDataInvalid()
        network.updateAccount(accountID: 542, request: request) { (result) in
            switch result {
                case .failure:
                    break
                case .success:
                    XCTFail("Invalid data should return error")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactions() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransactions(from: Date(timeIntervalSince1970: 1533124800), to: Date(timeIntervalSince1970: 1535673600)) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 179)
                    
                    if let firstTransaction = response.first {
                        XCTAssertEqual(firstTransaction.id, 99704)
                        XCTAssertEqual(firstTransaction.accountID, 544)
                        XCTAssertEqual(firstTransaction.amount.amount, "1000.00")
                        XCTAssertEqual(firstTransaction.amount.currency, "AUD")
                        XCTAssertEqual(firstTransaction.baseType, .credit)
                        XCTAssertEqual(firstTransaction.budgetCategory, .lifestyle)
                        XCTAssertEqual(firstTransaction.description.original, "Credit Card Payment")
                        XCTAssertEqual(firstTransaction.description.simple, "Payment")
                        XCTAssertEqual(firstTransaction.description.user, "My Payment")
                        XCTAssertEqual(firstTransaction.included, true)
                        XCTAssertEqual(firstTransaction.merchantID, 1)
                        XCTAssertEqual(firstTransaction.memo, "Remind me")
                        XCTAssertEqual(firstTransaction.postDate, "2018-03-01")
                        XCTAssertEqual(firstTransaction.status, .posted)
                        XCTAssertEqual(firstTransaction.categoryID, 81)
                        XCTAssertEqual(firstTransaction.transactionDate, "2018-08-08")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactions.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transactions_2018-08-01_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransactions(from: Date(timeIntervalSince1970: 1533124800), to: Date(timeIntervalSince1970: 1535673600)) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 176)
                    
                    if let firstTransaction = response.first {
                        XCTAssertEqual(firstTransaction.id, 99704)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 99703).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_99703", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransaction(transactionID: 99703) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 99703)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateTransaction() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transaction(transactionID: 99703).path) && isMethodPUT()) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_id_99703", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        let request = APITransactionUpdateRequest.testCompleteData()
        network.updateTransaction(transactionID: 99703, request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 99703)
                    XCTAssertEqual(response.accountID, 543)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategories() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransactionCategories() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 43)
                    
                    if let firstCategory = response.first {
                        XCTAssertEqual(firstCategory.id, 60)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategoriesSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.transactionCategories.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "transaction_categories_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchTransactionCategories() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 40)
                    
                    if let firstCategory = response.first {
                        XCTAssertEqual(firstCategory.id, 60)
                        
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchants() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_valid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchMerchants() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 1200)
                    
                    if let firstMerchant = response.first {
                        XCTAssertEqual(firstMerchant.id, 1)
                        
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchantsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchants.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchants_invalid", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchMerchants() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 1196)
                    
                    if let firstMerchant = response.first {
                        XCTAssertEqual(firstMerchant.id, 1)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchantByID() {
        let expectation1 = expectation(description: "Network Request")
        
        let url = URL(string: "https://api.example.com")!
        
        stub(condition: isHost(url.host!) && isPath("/" + AggregationEndpoint.merchant(merchantID: 197).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "merchant_id_197", ofType: "json")!, headers: [Network.HTTPHeader.contentType.rawValue: "application/json"])
        }
        
        let keychain = Keychain.validNetworkKeychain(service: keychainService)
        
        let network = Network(serverURL: url, keychain: keychain)
        
        network.fetchMerchant(merchantID: 197) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 197)
                    XCTAssertEqual(response.name, "Australia Post")
                    XCTAssertEqual(response.merchantType, .retailer)
                    XCTAssertEqual(response.smallLogoURL, "https://frollo-sandbox.s3.amazonaws.com/merchants/197/original/d6bd64365239f57dc09dd0711719077a_642234798c18e5ea343eefc97f511396e9d3d923d0473cc0e4a7d30a0fb46a30.png?1519084264")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
}
