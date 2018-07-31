//
//  ProviderTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class ProviderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdatingProviderCompleteData() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let providerResponse = APIProviderResponse.testCompleteData()
        
        let provider = Provider(context: managedObjectContext)
        provider.update(response: providerResponse)
        
        XCTAssertEqual(provider.providerID, providerResponse.id)
        XCTAssertEqual(provider.name, providerResponse.name)
        XCTAssertEqual(provider.smallLogoURL, URL(string: providerResponse.smallLogoURLString!)!)
        XCTAssertEqual(provider.status, providerResponse.status)
        XCTAssertEqual(provider.popular, providerResponse.popular)
        XCTAssertEqual(provider.largeLogoURL, URL(string: providerResponse.largeLogoURLString!)!)
        XCTAssertEqual(provider.helpMessage, providerResponse.helpMessage)
        XCTAssertEqual(provider.loginHelpMessage, providerResponse.loginHelpMessage)
        XCTAssertEqual(provider.loginURL, URL(string: providerResponse.loginURLString!)!)
        XCTAssertEqual(provider.baseURLString, providerResponse.baseURLString)
        XCTAssertEqual(provider.forgotPasswordURL, URL(string: providerResponse.forgotPasswordURLString!)!)
        XCTAssertEqual(provider.oAuthSite, providerResponse.oAuthSite)
        XCTAssertEqual(provider.authType, providerResponse.authType)
        XCTAssertEqual(provider.mfaType, providerResponse.mfaType)
        XCTAssertEqual(provider.encryptionType, providerResponse.encryption?.encryptionType)
        XCTAssertEqual(provider.encryptionAlias, providerResponse.encryption?.alias)
        XCTAssertEqual(provider.encryptionPublicKey, providerResponse.encryption?.pem)
        XCTAssertEqual(provider.containerBank, providerResponse.containerNames.contains(.bank))
        XCTAssertEqual(provider.containerBill, providerResponse.containerNames.contains(.bill))
        XCTAssertEqual(provider.containerCreditCard, providerResponse.containerNames.contains(.creditCard))
        XCTAssertEqual(provider.containerCreditScore, providerResponse.containerNames.contains(.creditScore))
        XCTAssertEqual(provider.containerInsurance, providerResponse.containerNames.contains(.insurance))
        XCTAssertEqual(provider.containerInvestment, providerResponse.containerNames.contains(.investment))
        XCTAssertEqual(provider.containerLoan, providerResponse.containerNames.contains(.loan))
        XCTAssertEqual(provider.containerRealEstate, providerResponse.containerNames.contains(.realEstate))
        XCTAssertEqual(provider.containerReward, providerResponse.containerNames.contains(.reward))
        XCTAssertEqual(provider.containerUnknown, providerResponse.containerNames.contains(.unknown))
    }
    
    func testUpdatingProviderIncompleteData() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let providerResponse = APIProviderResponse.testIncompleteData()
        
        let provider = Provider(context: managedObjectContext)
        provider.update(response: providerResponse)
        
        XCTAssertEqual(provider.providerID, providerResponse.id)
        XCTAssertEqual(provider.name, providerResponse.name)
        XCTAssertEqual(provider.smallLogoURL, URL(string: providerResponse.smallLogoURLString!)!)
        XCTAssertEqual(provider.status, providerResponse.status)
        XCTAssertEqual(provider.popular, providerResponse.popular)
        XCTAssertEqual(provider.largeLogoURL, nil)
        XCTAssertEqual(provider.helpMessage, providerResponse.helpMessage)
        XCTAssertEqual(provider.loginHelpMessage, providerResponse.loginHelpMessage)
        XCTAssertEqual(provider.loginURL, nil)
        XCTAssertEqual(provider.baseURLString, providerResponse.baseURLString)
        XCTAssertEqual(provider.forgotPasswordURL, nil)
        XCTAssertEqual(provider.oAuthSite, false)
        XCTAssertEqual(provider.authType, providerResponse.authType)
        XCTAssertEqual(provider.mfaType, providerResponse.mfaType)
        XCTAssertEqual(provider.encryptionType, nil)
        XCTAssertEqual(provider.encryptionAlias, providerResponse.encryption?.alias)
        XCTAssertEqual(provider.encryptionPublicKey, providerResponse.encryption?.pem)
        XCTAssertEqual(provider.containerBank, providerResponse.containerNames.contains(.bank))
        XCTAssertEqual(provider.containerBill, providerResponse.containerNames.contains(.bill))
        XCTAssertEqual(provider.containerCreditCard, providerResponse.containerNames.contains(.creditCard))
        XCTAssertEqual(provider.containerCreditScore, providerResponse.containerNames.contains(.creditScore))
        XCTAssertEqual(provider.containerInsurance, providerResponse.containerNames.contains(.insurance))
        XCTAssertEqual(provider.containerInvestment, providerResponse.containerNames.contains(.investment))
        XCTAssertEqual(provider.containerLoan, providerResponse.containerNames.contains(.loan))
        XCTAssertEqual(provider.containerRealEstate, providerResponse.containerNames.contains(.realEstate))
        XCTAssertEqual(provider.containerReward, providerResponse.containerNames.contains(.reward))
        XCTAssertEqual(provider.containerUnknown, providerResponse.containerNames.contains(.unknown))
        
    }
    
    func testUpdatingProviderWithIncompleteDataDoesNotOverwrite() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        let detailedProviderResponse = APIProviderResponse.testCompleteData()
        
        let provider = Provider(context: managedObjectContext)
        provider.update(response: detailedProviderResponse)
        
        let listProviderResponse = APIProviderResponse.testIncompleteData()
        provider.update(response: listProviderResponse)
        
        XCTAssertEqual(provider.providerID, listProviderResponse.id)
        XCTAssertEqual(provider.name, listProviderResponse.name)
        XCTAssertEqual(provider.smallLogoURL, URL(string: listProviderResponse.smallLogoURLString!)!)
        XCTAssertEqual(provider.status, listProviderResponse.status)
        XCTAssertEqual(provider.popular, listProviderResponse.popular)
        XCTAssertEqual(provider.largeLogoURL, URL(string: detailedProviderResponse.largeLogoURLString!)!)
        XCTAssertEqual(provider.helpMessage, detailedProviderResponse.helpMessage)
        XCTAssertEqual(provider.loginHelpMessage, detailedProviderResponse.loginHelpMessage)
        XCTAssertEqual(provider.loginURL, URL(string: detailedProviderResponse.loginURLString!)!)
        XCTAssertEqual(provider.baseURLString, detailedProviderResponse.baseURLString)
        XCTAssertEqual(provider.forgotPasswordURL, URL(string: detailedProviderResponse.forgotPasswordURLString!)!)
        XCTAssertEqual(provider.oAuthSite, detailedProviderResponse.oAuthSite)
        XCTAssertEqual(provider.authType, detailedProviderResponse.authType)
        XCTAssertEqual(provider.mfaType, detailedProviderResponse.mfaType)
        XCTAssertEqual(provider.encryptionType, detailedProviderResponse.encryption?.encryptionType)
        XCTAssertEqual(provider.encryptionAlias, detailedProviderResponse.encryption?.alias)
        XCTAssertEqual(provider.encryptionPublicKey, detailedProviderResponse.encryption?.pem)
        XCTAssertEqual(provider.containerBank, listProviderResponse.containerNames.contains(.bank))
        XCTAssertEqual(provider.containerBill, listProviderResponse.containerNames.contains(.bill))
        XCTAssertEqual(provider.containerCreditCard, listProviderResponse.containerNames.contains(.creditCard))
        XCTAssertEqual(provider.containerCreditScore, listProviderResponse.containerNames.contains(.creditScore))
        XCTAssertEqual(provider.containerInsurance, listProviderResponse.containerNames.contains(.insurance))
        XCTAssertEqual(provider.containerInvestment, listProviderResponse.containerNames.contains(.investment))
        XCTAssertEqual(provider.containerLoan, listProviderResponse.containerNames.contains(.loan))
        XCTAssertEqual(provider.containerRealEstate, listProviderResponse.containerNames.contains(.realEstate))
        XCTAssertEqual(provider.containerReward, listProviderResponse.containerNames.contains(.reward))
        XCTAssertEqual(provider.containerUnknown, listProviderResponse.containerNames.contains(.unknown))
    }
    
}
