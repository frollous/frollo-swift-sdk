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

import Foundation
@testable import FrolloSDK

extension Provider: TestableCoreData {
    
    func populateTestData() {
        providerID = Int64.random(in: 1...Int64.max)
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
    
    func populateTestData(withID id: Int64) {
        populateTestData()
        
        providerID = id
    }
    
}

