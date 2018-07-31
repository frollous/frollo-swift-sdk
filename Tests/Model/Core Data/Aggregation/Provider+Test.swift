//
//  Provider+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Provider {
    
    func populateTestData() {
        providerID = Int64(arc4random())
        name = UUID().uuidString
        smallLogoURLString = "https://example.com/small.png"
        status = .supported
        popular = false
        largeLogoURLString = "https://example.com/large.png"
        containerBank = true
        containerBill = true
        containerCreditCard = true
        containerCreditScore = true
        containerInsurance = true
        containerInvestment = true
        containerRealEstate = true
        containerReward = true
        containerLoan = true
        containerUnknown = false
        helpMessage = UUID().uuidString
        loginHelpMessage = UUID().uuidString
        loginURLString = "https://example.com/login"
        baseURLString = "https://example.com/"
        forgotPasswordURLString = "https://example.com/iforgot"
        oAuthSite = true
        mfaType = .token
        encryptionType = .encryptValues
        encryptionAlias = UUID().uuidString
        encryptionPublicKey = UUID().uuidString
    }
    
}

