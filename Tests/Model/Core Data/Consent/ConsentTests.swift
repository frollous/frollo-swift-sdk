//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

@testable import FrolloSDK

class ConsentTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatingConsent() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let consentResponse = APICDRConsentResponse.testCompleteData()
            
            let consent = Consent(context: managedObjectContext)
            consent.update(response: consentResponse, context: managedObjectContext)
            
            XCTAssertEqual(consent.consentID, consentResponse.id)
            XCTAssertEqual(consent.providerID, consentResponse.providerID)
            XCTAssertEqual(consent.providerAccountID, consentResponse.providerAccountID)
            XCTAssertEqual(consent.sharingDuration, consentResponse.sharingDuration)
            XCTAssertEqual(consent.additionalPermissions, consentResponse.additionalPermissions)
            XCTAssertEqual(consent.status, Consent.Status(rawValue: consentResponse.status))
            XCTAssertEqual(consent.authorizationURLString, consentResponse.authorisationRequestURL)
            XCTAssertEqual(consent.confirmationPDFURLString, consentResponse.confirmationPDFURL)
            XCTAssertEqual(consent.withdrawalPDFURLString, consentResponse.withdrawalPDFURL)
            XCTAssertEqual(consent.sharingStartedAtRawValue, consentResponse.sharingStartedAt)
            XCTAssertEqual(consent.sharingStoppedAtRawValue, consentResponse.sharingStoppedAt)
            XCTAssertEqual(consent.permissions.count, consentResponse.permissions.count)
        }
    }

}
