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

class DataErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPIInvalidData() {
        let error = DataError(type: .api, subType: .invalidData)
        XCTAssertEqual(error.type, .api)
        XCTAssertEqual(error.subType, .invalidData)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.API.InvalidData"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.api.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testAPIErrorUnknown() {
        let error = DataError(type: .api, subType: .unknown)
        XCTAssertEqual(error.type, .api)
        XCTAssertEqual(error.subType, .unknown)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.API.Unknown"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.api.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testAuthenticationMissingAccessToken() {
        let error = DataError(type: .authentication, subType: .missingAccessToken)
        XCTAssertEqual(error.type, .authentication)
        XCTAssertEqual(error.subType, .missingAccessToken)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Authentication.MissingAccessToken"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.authentication.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testAuthenticationMissingRefreshToken() {
        let error = DataError(type: .authentication, subType: .missingRefreshToken)
        XCTAssertEqual(error.type, .authentication)
        XCTAssertEqual(error.subType, .missingRefreshToken)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Authentication.MissingRefreshToken"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.authentication.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testAuthenticationErrorUnknown() {
        let error = DataError(type: .authentication, subType: .unknown)
        XCTAssertEqual(error.type, .authentication)
        XCTAssertEqual(error.subType, .unknown)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Authentication.Unknown"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.authentication.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorCorrupt() {
        let error = DataError(type: .database, subType: .corrupt)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .corrupt)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.Corrupted"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorDiskFull() {
        let error = DataError(type: .database, subType: .diskFull)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .diskFull)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.DiskFullError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorMigrationFailed() {
        let error = DataError(type: .database, subType: .migrationFailed)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .migrationFailed)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.MigrationFailed"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorNotFound() {
        let error = DataError(type: .database, subType: .notFound)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .notFound)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.NotFound"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testDatabaseErrorUnknown() {
        let error = DataError(type: .database, subType: .unknown)
        XCTAssertEqual(error.type, .database)
        XCTAssertEqual(error.subType, .unknown)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Database.UnknownError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.database.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testGenericErrorUnknown() {
        let error = DataError(type: .unknown, subType: .unknown)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertEqual(error.subType, .unknown)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Generic.UnknownError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.unknown.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testErrorMismatchIsUnknown() {
        let error = DataError(type: .unknown, subType: .corrupt)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertEqual(error.subType, .corrupt)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Generic.UnknownError"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.unknown.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testAlreadyLoggedIn() {
        let error = DataError(type: .authentication, subType: .alreadyLoggedIn)
        XCTAssertEqual(error.type, .authentication)
        XCTAssertEqual(error.subType, .alreadyLoggedIn)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Authentication.AlreadyLoggedIn"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.authentication.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
    func testLoggedOut() {
        let error = DataError(type: .authentication, subType: .loggedOut)
        XCTAssertEqual(error.type, .authentication)
        XCTAssertEqual(error.subType, .loggedOut)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.Data.Authentication.LoggedOut"))
        XCTAssertTrue(error.debugDescription.contains(DataError.DataErrorType.authentication.rawValue))
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
    }
    
}
