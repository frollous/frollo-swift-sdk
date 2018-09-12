//
//  Provider+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Provider: TestableCoreData {
    
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
        encryptionAlias = "09282016_1"
        encryptionPublicKey = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1eXKHvPBlS4A41OvQqFn0SfNH7OgEs2MXMLeyp3xKorEipEKuzv/JDtHFHRAfYwyeiC0q+me0R8GLA6NEDGDfpxGv/XUFyza609ZqtCTOiGCp8DcjLG0mPljdGA1Df0BKhF3y5uata1y0dKSI8aY8lXPza+Tsw4TtjdmHbJ2rR3sFZkYch1RTmNKxKDxMgUmtIk785lIfLJ2x6lvh4ZS9QhuAnsoVM91WWKHrLHYfAeA/zD1TxHDm5/4wPbmFLEBe2+5zGae19nsA/9zDwKP4whpte9HuDDQa5Vsq+aWj5pDJuvFgwA/DStqcHGijn5gzB/JXEoE9qx+dcG92PpvfwIDAQAB\n------END PUBLIC KEY------"
    }
    
}

