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

import OHHTTPStubs
import SwiftyJSON

class AggregationRequestTests: BaseTestCase {
    
    var keychain: Keychain!
    var service: APIService!
    
    override func setUp() {
        testsKeychainService = "AggregationRequestTests"
        super.setUp()
        keychain = defaultKeychain(isNetwork: true)
        service = defaultService(keychain: keychain)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        Keychain(service: keychainService).removeAll()
        HTTPStubs.removeAllStubs()
    }
    
    func testFetchProviders() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.providers.path.prefixedWithSlash, toResourceWithName: "providers_valid")
        
        service.fetchProviders { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 50)
                    
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
    
    func testFetchProviderByID() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.provider(providerID: 12345).path.prefixedWithSlash, toResourceWithName: "provider_id_12345")
        
        service.fetchProvider(providerID: 12345) { (result) in
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
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_valid")
        
        service.fetchProviderAccounts { (result) in
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
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_accounts_invalid")
        
        service.fetchProviderAccounts { (result) in
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
        
        connect(endpoint: AggregationEndpoint.providerAccount(providerAccountID: 123).path.prefixedWithSlash, toResourceWithName: "provider_account_id_123")
        
        service.fetchProviderAccount(providerAccountID: 123) { (result) in
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
        
        connect(endpoint: AggregationEndpoint.providerAccounts.path.prefixedWithSlash, toResourceWithName: "provider_account_id_123", addingStatusCode: 201)
        
        let mockAuthentication = MockAuthentication()
        let authentication = Authentication(configuration: config)
        authentication.dataSource = mockAuthentication
        authentication.delegate = mockAuthentication
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let filledForm = ProviderLoginForm.loginFormFilledData()
        let request = APIProviderAccountCreateRequest(loginForm: filledForm, providerID: 4078, consentID: nil)
        
        service.createProviderAccount(request: request) { (result) in
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
        
        connect(endpoint: AggregationEndpoint.providerAccount(providerAccountID: 12345).path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        service.deleteProviderAccount(providerAccountID: 12345) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        HTTPStubs.removeAllStubs()
    }
    
    func testFetchAccounts() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.accounts.path.prefixedWithSlash, toResourceWithName: "accounts_valid")
        
        service.fetchAccounts { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 8)
                    
                    if let firstAccount = response.first {
                                                
                        XCTAssertEqual(firstAccount.id, 542)
                        XCTAssertEqual(firstAccount.providerAccountID, 867)
                        XCTAssertEqual(firstAccount.accountNumber, "31014562")
                        XCTAssertEqual(firstAccount.bsb, "062-181")
                        XCTAssertEqual(firstAccount.features?.first?.id, .payments)
                        XCTAssertEqual(firstAccount.features?[1].id, .transfers)
                        XCTAssertEqual(firstAccount.features?[2].id, .statements)
                        XCTAssertEqual(firstAccount.features?.first?.details?.first?.id, .bpay)
                        XCTAssertEqual(firstAccount.features?.first?.details?[1].id, .npp)
                        XCTAssertEqual(firstAccount.features?.first?.details?[2].id, .payAnyone)
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
                        XCTAssertEqual(firstAccount.goalIDs, [98, 785, 22222091])
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchAccountsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.accounts.path.prefixedWithSlash, toResourceWithName: "accounts_invalid")
        
        service.fetchAccounts { (result) in
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
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        service.fetchAccount(accountID: 542) { (result) in
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
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        let request = APIAccountUpdateRequest.testUpdateDataValid()
        service.updateAccount(accountID: 542, request: request) { (result) in
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
        
        connect(endpoint: AggregationEndpoint.account(accountID: 542).path.prefixedWithSlash, toResourceWithName: "account_id_542")
        
        let request = APIAccountUpdateRequest.testUpdateDataInvalid()
        service.updateAccount(accountID: 542, request: request) { (result) in
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
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_single_page")
        
        service.fetchTransactions(transactionFilter: nil) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.elements.count, 34)
                    
                    if let firstTransaction = response.data.elements.first {
                        XCTAssertEqual(firstTransaction.id, 168476)
                        XCTAssertEqual(firstTransaction.accountID, 2150)
                        XCTAssertEqual(firstTransaction.billID, 1024)
                        XCTAssertEqual(firstTransaction.billPaymentID, 1025)
                        XCTAssertEqual(firstTransaction.amount.amount, "-10.24")
                        XCTAssertEqual(firstTransaction.amount.currency, "AUD")
                        XCTAssertEqual(firstTransaction.baseType, .debit)
                        XCTAssertEqual(firstTransaction.budgetCategory, .living)
                        XCTAssertEqual(firstTransaction.description.original, "WOOLWORTHS W1766         KOGARAH      AU Card xx0996")
                        XCTAssertEqual(firstTransaction.description.simple, "Woolworths")
                        XCTAssertEqual(firstTransaction.description.user, nil)
                        XCTAssertEqual(firstTransaction.included, true)
                        XCTAssertEqual(firstTransaction.merchant.id, 2)
                        XCTAssertEqual(firstTransaction.merchant.name, "Woolworths")
                        XCTAssertEqual(firstTransaction.merchant.phone, "(02) 8565 9336")
                        XCTAssertEqual(firstTransaction.merchant.website, "https://www.woolworths.com.au")
                        XCTAssertEqual(firstTransaction.merchant.location?.line2, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.line3, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.suburb, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.state, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.postcode, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.country, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.latitude, nil)
                        XCTAssertEqual(firstTransaction.merchant.location?.longitude, nil)
                        XCTAssertEqual(firstTransaction.memo, nil)
                        XCTAssertEqual(firstTransaction.postDate, "2020-01-25")
                        XCTAssertEqual(firstTransaction.status, .posted)
                        XCTAssertEqual(firstTransaction.categoryID, 66)
                        XCTAssertEqual(firstTransaction.transactionDate, "2020-01-25")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.transactions().path.prefixedWithSlash, toResourceWithName: "transactions_2018-08-01_invalid")
        
        service.fetchTransactions(transactionFilter: nil) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.elements.count, 30)
                    
                    if let firstTransaction = response.data.elements.first {
                        XCTAssertEqual(firstTransaction.id, 168476)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionByID() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        service.fetchTransaction(transactionID: 194630) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 194630)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateTransaction() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.transaction(transactionID: 194630).path.prefixedWithSlash, toResourceWithName: "transaction_id_194630")
        
        let request = APITransactionUpdateRequest.testCompleteData()
        service.updateTransaction(transactionID: 194630, request: request) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.id, 194630)
                    XCTAssertEqual(response.accountID, 939)
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategories() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.transactionCategories.path.prefixedWithSlash, toResourceWithName: "transaction_categories_valid")
        
        service.fetchTransactionCategories() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 63)
                    
                    if let firstCategory = response.first {
                        XCTAssertEqual(firstCategory.id, 60)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionUserTags() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.transactionUserTags.path.prefixedWithSlash, toResourceWithName: "transactions_user_tags")
        
        service.fetchTransactionUserTags(searchTerm: "term", sort: .name, order: .asc) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.count, 7)
                    
                    if let firstTag = response.first {
                        XCTAssertEqual(firstTag.name, "brew")
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchTransactionCategoriesSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.transactionCategories.path.prefixedWithSlash, toResourceWithName: "transaction_categories_invalid")
        
        service.fetchTransactionCategories() { (result) in
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
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_valid")
        
        service.fetchMerchants(size: 20) { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.elements.count, 1199)

                    if let firstMerchant = response.data.elements.first {
                        XCTAssertEqual(firstMerchant.id, 1)
                    }
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchantsSkipsInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.merchants.path.prefixedWithSlash, toResourceWithName: "merchants_invalid")
        
        service.fetchMerchants() { (result) in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success(let response):
                    XCTAssertEqual(response.data.elements.count, 6)

                    if let firstMerchant = response.data.elements.first {
                        XCTAssertEqual(firstMerchant.id, 1)
                    }
            }

            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testFetchMerchantByID() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: AggregationEndpoint.merchant(merchantID: 197).path.prefixedWithSlash, toResourceWithName: "merchant_id_197")
        
        service.fetchMerchant(merchantID: 197) { (result) in
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
