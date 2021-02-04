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
import Alamofire

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
        let authentication = Authentication(configuration: config)
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
        let authentication = Authentication(configuration: config)
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
        let authentication = Authentication(configuration: config)
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
        
        connect(endpoint: UserEndpoint.resetPassword.path.prefixedWithSlash, addingData: "".data(using: .utf8)!, addingStatusCode: 202)
        
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
        let exp = expectation(description: "Adapt")
        let keychain = validKeychain()
        let authentication = defaultAuthentication(keychain: keychain)
        
        let requestURL = URL(string: "https://api.example.com/somewhere")!
        let request = URLRequest(url: requestURL)

        authentication.adapt(request, for: Session.default, completion: {
            result in
            switch result {
            case .success(let adaptedRequest):
                guard let authHeader = adaptedRequest.allHTTPHeaderFields?["Authorization"]
                    else {
                        XCTFail("No auth header")
                        return
                }

                XCTAssertTrue(authHeader.contains("Bearer"))
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        })

        wait(for: [exp], timeout: 3)
    }

    func testRequestNewOTP() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.requestOTP.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_request_otp", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.requestNewOTPCodeForUser { result in
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

    }

    func testFetchUnconfimedUserDetails() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.unconfirmedDetails.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_confirm_details", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        user.fetchUnconfimedUserDetails { (result) in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let data):
                XCTAssertNotNil(data.mobileNumber)
            }

            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: 3.0)

    }

    func testConfirmUserDetails() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.confirmDetails.path)) { (request) -> OHHTTPStubsResponse in
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

            user.confimUserDetails(mobileNumber: "+64111111111") { (result) in
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
    }

    func testLogging() {
        let expectation1 = expectation(description: "User feedback message logging")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + DeviceEndpoint.log.path)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.sendLog(message: "User test feedback message", level: .off) { (result) in
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
    }

    func testFetchPayIDList() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.payID.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_get_payid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.fetchPayIDs { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let data):
                        XCTAssertEqual(data.count, 2)
                        break
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }

    func testRequestPayIDOTP() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.payIDOTP.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_request_payid_otp", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.requestOTPForPayIDRegistration(payID: "user@example.com", type: .email) { result in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let id):
                        XCTAssertEqual(id, "VE86849f8805b0906b4a8360bce8c025db")
                        break
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)

    }

    func testRegisterPayID() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.payID.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_register_payid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.registerPayID(accountID: 325, payID: "+61411111111", type: .phoneNumber, trackingID: "VE20db0310501c4d7cc347c8d897967039", otpCode: "444684") { result in
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

    }

    func testRemovePayID() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.removePayID.path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_register_payid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.removePayID(payID: "+61411111111", type: .phoneNumber) { result in
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

    }

    func testFetchPayIDListForAccount() {
        let expectation1 = expectation(description: "Network Request")

        let config = FrolloSDKConfiguration.testConfig()

        stub(condition: isHost(config.serverEndpoint.host!) && isPath("/" + UserEndpoint.accountPayID(accountID: 325).path)) { (request) -> OHHTTPStubsResponse in
            return fixture(filePath: Bundle(for: type(of: self)).path(forResource: "user_get_account_payid", ofType: "json")!, headers: [ HTTPHeader.contentType.rawValue: "application/json"])
        }

        let keychain = validKeychain()
        let networkAuthenticator = defaultAuthentication(keychain: keychain)
        let network = Network(serverEndpoint: config.serverEndpoint, authentication: networkAuthenticator)
        let service = APIService(serverEndpoint: config.serverEndpoint, network: network)

        let authentication = defaultOAuth2Authentication(keychain: keychain, loggedIn: true)
        let user = UserManagement(database: database, service: service, clientID: config.clientID, authentication: authentication, preferences: preferences, delegate: nil)

        database.setup { (error) in
            XCTAssertNil(error)

            user.fetchPayIDs(for: 325) { (result) in
                switch result {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .success(let data):
                        XCTAssertEqual(data.count, 1)
                        break
                }

                expectation1.fulfill()
            }
        }

        wait(for: [expectation1], timeout: 3.0)
    }
}
