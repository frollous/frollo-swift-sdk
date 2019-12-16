//
//  Copyright © 2018 Frollo. All rights reserved.
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

import OHHTTPStubs

class UserManagementTests: BaseTestCase {

    override func setUp() {
        testsKeychainService = "UserManagementTestsKeychain"
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Keychain(service: keychainService).removeAll()
    }

    private func validKeychain() -> Keychain {
        let keychain = Keychain(service: keychainService)
        keychain["refreshToken"] = "AnExistingRefreshToken"
        keychain["accessToken"] = "AnExistingAccessToken"
        keychain["accessTokenExpiry"] = String(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970) // Not expired by time
        return keychain
    }
    
    // MARK: - Register User
    
    func testRegisterUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "user_details_complete", addingStatusCode: 201)
        
        let user = defaultUser(loggedIn: false)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertNotNil(user.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testRegisterUserInvalid() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(host: tokenEndpointHost, endpoint: FrolloSDKConfiguration.tokenEndpoint.path, toResourceWithName: "token_valid")
        connect(endpoint: UserEndpoint.register.path.prefixedWithSlash, toResourceWithName: "error_duplicate", addingStatusCode: 409)
        
        let keychain = defaultKeychain(isNetwork: false)
        let oAuth2Authentication = defaultOAuth2Authentication()
        let user = defaultUser(keychain: keychain, loggedIn: false)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.registerUser(firstName: "Frollo", lastName: "User", mobileNumber: "0412345678", postcode: "2060", dateOfBirth: Date(timeIntervalSince1970: 631152000), email: "user@frollo.us", password: "password") { (result) in
                switch result {
                    case .failure(let error):
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(user.fetchUser(context: self.database.newBackgroundContext()))
                        
                        XCTAssertNil(oAuth2Authentication.accessToken)
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        
                        if let apiError = error as? APIError {
                            XCTAssertEqual(apiError.type, .alreadyExists)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Invalid registration data should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - User Details
    
    func testRefreshUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.refreshUser { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertNotNil(user.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path.prefixedWithSlash, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.updateUser { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    XCTAssertNotNil(user.fetchUser(context: self.database.newBackgroundContext()))
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUserFailsIfMissingToken() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain, loggedIn: false)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.updateUser { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .authentication)
                            XCTAssertEqual(dataError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type")
                        }
                    case .success:
                        XCTFail("Logged out, should fail")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateUserFailsIfNonexistant() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.details.path, toResourceWithName: "user_details_complete")
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.updateUser { (result) in
                switch result {
                case .failure(let error):
                    XCTAssertNil(user.fetchUser(context: self.database.viewContext))
                    
                    if let dataError = error as? DataError {
                        XCTAssertEqual(dataError.type, .database)
                        XCTAssertEqual(dataError.subType, .notFound)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("User missing. Should fail.")
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testChangePassword() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.changePassword(currentPassword: UUID().uuidString, newPassword: UUID().uuidString, completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        break
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testChangePasswordAPIFailure() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 500)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        user.changePassword(currentPassword: UUID().uuidString, newPassword: UUID().uuidString, completion: { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                
                    if let apiError = error as? APIError {
                        XCTAssertEqual(apiError.type, .serverError)
                        XCTAssertEqual(apiError.statusCode, 500)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("Request should fail")
            }
            
            expectation1.fulfill()
        })
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testChangePasswordFailsIfTooShort() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.changePassword(currentPassword: UUID().uuidString, newPassword: "1234", completion: { (result) in
                switch result {
                case .failure(let error):
                    if let dataError = error as? DataError {
                        XCTAssertEqual(dataError.type, .api)
                        XCTAssertEqual(dataError.subType, .passwordTooShort)
                    } else {
                        XCTFail("Wrong error returned")
                    }
                case .success:
                    XCTFail("Change password should fail")
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testDeleteUser() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let user = defaultUser(keychain: keychain, authentication: authentication, delegate: nil)
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.deleteUser(completion: { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testDeleteUserFailsIfLoggedOut() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.user.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain, loggedIn: false)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.deleteUser(completion: { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .authentication)
                            XCTAssertEqual(dataError.subType, .missingAccessToken)
                        } else {
                            XCTFail("Wrong error type")
                        }
                    case .success:
                        XCTFail("User logged out. Should fail")
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testMigrateUser() {
        let expectation1 = expectation(description: "Network Request")
        let expectation2 = expectation(description: "Reset")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.migrate.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }
        
        let keychain = validKeychain()
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        let mockFrollo = MockFrolloDelegate {
            authentication.reset()
            oAuth2Authentication.reset()
            
            expectation2.fulfill()
        }
        
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: oAuth2Authentication, preferences: preferences, delegate: mockFrollo)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.migrateUser(password: "12345678") { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success:
                        XCTAssertFalse(oAuth2Authentication.loggedIn)
                        
                        XCTAssertNil(oAuth2Authentication.refreshToken)
                        XCTAssertNil(oAuth2Authentication.accessToken)
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 3.0)
    }
    
    func testMigrateUserAIPFailure() {
        let expectation1 = expectation(description: "Network Request")
        
        let config = FrolloSDKConfiguration.testConfig()
        
        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.migrate.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 500, headers: nil)
        }
        
        let keychain = validKeychain()
        let oAuth2Authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let authentication = Authentication(serverEndpoint: config.serverEndpoint)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: authentication)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        authentication.dataSource = oAuth2Authentication
        authentication.delegate = oAuth2Authentication
        
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: oAuth2Authentication, preferences: preferences, delegate: nil)
        
        user.migrateUser(password: "12345678") { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    if let apiError = error as? APIError {
                        XCTAssertEqual(apiError.type, .serverError)
                        XCTAssertEqual(apiError.statusCode, 500)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("Request should fail")
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 3.0)
    }

    func testMigrateUserFailsIfMissingRefreshToken() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.migrate.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }

        let keychain = Keychain(service: "EmptyMe")
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.migrateUser(password: "12345678") { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .authentication)
                            XCTAssertEqual(dataError.subType, .missingRefreshToken)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Change password should fail")
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testMigrateUserFailsIfPasswordTooShort() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.migrate.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)
        
        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)
        
        database.setup { (error) in
            XCTAssertNil(error)

            user.migrateUser(password: "1234") { (result) in
                switch result {
                    case .failure(let error):
                        if let dataError = error as? DataError {
                            XCTAssertEqual(dataError.type, .api)
                            XCTAssertEqual(dataError.subType, .passwordTooShort)
                        } else {
                            XCTFail("Wrong error returned")
                        }
                    case .success:
                        XCTFail("Change password should fail")
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
    
    func testResetPassword() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.resetPassword.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 202)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            let moc = self.database.newBackgroundContext()
            
            moc.performAndWait {
                let user = User(context: moc)
                user.populateTestData()
                
                try! moc.save()
            }
            
            user.resetPassword(email: "test@domain.com", completion: { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testResetPasswordAPIFailure() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: UserEndpoint.resetPassword.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 500)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
         user.resetPassword(email: "test@domain.com", completion: { (result) in
            switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    if let apiError = error as? APIError {
                        XCTAssertEqual(apiError.type, .serverError)
                        XCTAssertEqual(apiError.statusCode, 500)
                    } else {
                        XCTFail("Wrong error type returned")
                    }
                case .success:
                    XCTFail("Request should fail")
            }
            
            expectation1.fulfill()
        })
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - Device
    
    func testUpdateDevice() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: DeviceEndpoint.device.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.updateDevice(notificationToken: "SomeToken12345", completion: { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
                }
                
                expectation1.fulfill()
            })
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    func testUpdateDeviceCompliance() {
        let expectation1 = expectation(description: "Network Request")
        
        connect(endpoint: DeviceEndpoint.device.path.prefixedWithSlash, addingData: Data(), addingStatusCode: 204)
        
        let keychain = validKeychain()
        let user = defaultUser(keychain: keychain)
        
        database.setup { (error) in
            XCTAssertNil(error)
            
            user.updateDeviceCompliance(true) { (result) in
                switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .success:
                    break
                }
                
                expectation1.fulfill()
            }
        }
        
        wait(for: [expectation1], timeout: 3.0)
        
        try? FileManager.default.removeItem(at: tempFolderPath())
    }
    
    // MARK: - Web view
    
    func testAuthenticatingRequestManually() {
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain)
        
        let requestURL = URL(string: "https://api.example.com/somewhere")!
        let request = URLRequest(url: requestURL)
        do {
            let adaptedRequest = try authentication.adapt(request)
            
            guard let authHeader = adaptedRequest.allHTTPHeaderFields?["Authorization"]
                else {
                    XCTFail("No auth header")
                    return
            }
            
            XCTAssertTrue(authHeader.contains("Bearer"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
