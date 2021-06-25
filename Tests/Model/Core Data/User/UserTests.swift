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

import CoreData
import XCTest
@testable import FrolloSDK

class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testUserModelUpdate() {
        let expectation1 = expectation(description: "Database setup")
        
        let path = tempFolderPath()
        
        let database = Database(path: path)
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = database.newBackgroundContext()
            
            moc.performAndWait {
                let userModel = User(context: moc)
                userModel.populateTestData()
                
                let userResponseModel = APIUserResponse.testData()
                
                userModel.update(response: userResponseModel)
                
                XCTAssertEqual(userModel.userID, userResponseModel.userID)
                XCTAssertEqual(userModel.firstName, userResponseModel.firstName)
                XCTAssertEqual(userModel.lastName, userResponseModel.lastName)
                XCTAssertEqual(userModel.email, userResponseModel.email)
                XCTAssertEqual(userModel.emailVerified, userResponseModel.emailVerified)
                XCTAssertEqual(userModel.status, userResponseModel.status)
                XCTAssertEqual(userModel.primaryCurrency, userResponseModel.primaryCurrency)
                XCTAssertEqual(userModel.gender, userResponseModel.gender)
                XCTAssertEqual(userModel.dateOfBirth, userResponseModel.dateOfBirth)
                XCTAssertEqual(userModel.address?.id, 0)
                XCTAssertEqual(userModel.householdType, userResponseModel.householdType)
                XCTAssertEqual(userModel.occupation, userResponseModel.occupation)
                XCTAssertEqual(userModel.industry, userResponseModel.industry)
                XCTAssertEqual(userModel.householdSize, userResponseModel.householdSize)
                XCTAssertEqual(userModel.facebookID, userResponseModel.facebookID)
                XCTAssertEqual(userModel.validPassword, userResponseModel.validPassword)
                XCTAssertEqual(userModel.features, userResponseModel.features)
                XCTAssertEqual(userModel.mobileNumber, userResponseModel.mobileNumber)
                XCTAssertEqual(userModel.address?.longForm, "")
                XCTAssertEqual(userModel.mailingAddress?.id, 1)
                XCTAssertEqual(userModel.previousAddress?.id, 2)
                XCTAssertEqual(userModel.attributionAdGroup, userResponseModel.attribution?.adGroup)
                XCTAssertEqual(userModel.attributionCampaign, userResponseModel.attribution?.campaign)
                XCTAssertEqual(userModel.attributionCreative, userResponseModel.attribution?.creative)
                XCTAssertEqual(userModel.attributionNetwork, userResponseModel.attribution?.network)
                XCTAssertEqual(userModel.registerSteps, userResponseModel.registerSteps)
                
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testUpdateUserRequest() {
        let database = Database(path: tempFolderPath())
        
        let managedObjectContext = database.newBackgroundContext()
        
        managedObjectContext.performAndWait {
            let user = User(context: managedObjectContext)
            user.populateTestData()
            
            let updateRequest = user.updateRequest()
            
            XCTAssertEqual(user.firstName, updateRequest.firstName)
            XCTAssertEqual(user.lastName, updateRequest.lastName)
            XCTAssertEqual(user.email, updateRequest.email)
            XCTAssertEqual(user.mobileNumber, updateRequest.mobileNumber)
            XCTAssertEqual(user.gender, updateRequest.gender)
            XCTAssertEqual(user.dateOfBirth, updateRequest.dateOfBirth)
            XCTAssertEqual(user.address?.id, 0)
            XCTAssertEqual(user.mailingAddress?.id, 1)
            XCTAssertEqual(user.householdType, updateRequest.householdType)
            XCTAssertEqual(user.householdSize, updateRequest.householdSize)
            XCTAssertEqual(user.occupation, updateRequest.occupation)
            XCTAssertEqual(user.industry, updateRequest.industry)
            XCTAssertEqual(user.primaryCurrency, updateRequest.primaryCurrency)
            XCTAssertEqual(user.attributionAdGroup, updateRequest.attribution?.adGroup)
            XCTAssertEqual(user.attributionCampaign, updateRequest.attribution?.campaign)
            XCTAssertEqual(user.attributionCreative, updateRequest.attribution?.creative)
            XCTAssertEqual(user.attributionNetwork, updateRequest.attribution?.network)
            XCTAssertEqual(user.tin, updateRequest.tin)
            XCTAssertEqual(user.tfn, updateRequest.tfn)
            XCTAssertEqual(user.taxResidency, updateRequest.taxResidency)
            XCTAssertEqual(user.foreignTax, updateRequest.foreignTax)
        }
    }
    
}
