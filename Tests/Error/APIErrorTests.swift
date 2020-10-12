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

class APIErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    func errorJSONNamed(_ fileName: String) -> Data {
        let errorJSONPath = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: errorJSONPath)
    }
    
    // MARK: - Bad Request Tests
    
    func testAPIErrorInvalidValue() {
        let errorJSON = errorJSONNamed("error_invalid_value")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, .invalidValue)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInvalidLength() {
        let errorJSON = errorJSONNamed("error_invalid_length")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, .invalidLength)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInvalidAuthHeader() {
        let errorJSON = errorJSONNamed("error_invalid_auth_head")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, .invalidAuthorisationHeader)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInvalidUserAgent() {
        let errorJSON = errorJSONNamed("error_invalid_user_agent")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, .invalidUserAgentHeader)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorValueMustDiffer() {
        let errorJSON = errorJSONNamed("error_value_must_differ")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.PasswordMustBeDifferent"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .passwordMustBeDifferent)
        XCTAssertEqual(error.errorCode, .invalidMustBeDifferent)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorValueOverLimit() {
        let errorJSON = errorJSONNamed("error_value_over_limit")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, .invalidOverLimit)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInvalidCount() {
        let errorJSON = errorJSONNamed("error_invalid_count")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, .invalidCount)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorAggregatorBadRequest() {
        let errorJSON = errorJSONNamed("error_aggregator_bad_request")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.AggregatorBadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .aggregatorBadRequest)
        XCTAssertEqual(error.errorCode, .aggregatorBadRequest)
        XCTAssertNotNil(error.message)
    }
    
    // MARK: - Authorisation Tests
    
    func testAPIErrorInvalidAccessToken() {
        let errorJSON = errorJSONNamed("error_invalid_access_token")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.InvalidAccessToken"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .invalidAccessToken)
        XCTAssertEqual(error.errorCode, .invalidAccessToken)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInvalidRefreshToken() {
        let errorJSON = errorJSONNamed("error_invalid_refresh_token")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.InvalidRefreshToken"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .invalidRefreshToken)
        XCTAssertEqual(error.errorCode, .invalidRefreshToken)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInvalidUsernamePasswordToken() {
        let errorJSON = errorJSONNamed("error_invalid_username_password")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.InvalidUsernamePassword"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .invalidUsernamePassword)
        XCTAssertEqual(error.errorCode, .invalidUsernamePassword)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorSuspendedDevice() {
        let errorJSON = errorJSONNamed("error_suspended_device")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.SuspendedDevice"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .suspendedDevice)
        XCTAssertEqual(error.errorCode, .suspendedDevice)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorSuspendedUser() {
        let errorJSON = errorJSONNamed("error_suspended_user")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.SuspendedUser"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .suspendedUser)
        XCTAssertEqual(error.errorCode, .suspendedUser)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorAccountLocked() {
        let errorJSON = errorJSONNamed("error_account_locked")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.AccountLocked"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .accountLocked)
        XCTAssertEqual(error.errorCode, .accountLocked)
        XCTAssertNotNil(error.message)
    }
    
    // MARK: - Other Tests
    
    func testAPIErrorNotAuthorised() {
        let errorJSON = errorJSONNamed("error_not_allowed")
        
        let error = APIError(statusCode: 403, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.Unauthorised"))
        XCTAssertEqual(error.statusCode, 403)
        XCTAssertEqual(error.type, .unauthorised)
        XCTAssertEqual(error.errorCode, .unauthorised)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorNotFound() {
        let errorJSON = errorJSONNamed("error_not_found")
        
        let error = APIError(statusCode: 404, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.NotFound"))
        XCTAssertEqual(error.statusCode, 404)
        XCTAssertEqual(error.type, .notFound)
        XCTAssertEqual(error.errorCode, .notFound)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorConflict() {
        let errorJSON = errorJSONNamed("error_duplicate")
        
        let error = APIError(statusCode: 409, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.UserAlreadyExists"))
        XCTAssertEqual(error.statusCode, 409)
        XCTAssertEqual(error.type, .alreadyExists)
        XCTAssertEqual(error.errorCode, .alreadyExists)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorAggregatorError() {
        let errorJSON = errorJSONNamed("error_aggregator")
        
        let error = APIError(statusCode: 503, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.ServerError"))
        XCTAssertEqual(error.statusCode, 503)
        XCTAssertEqual(error.type, .serverError)
        XCTAssertEqual(error.errorCode, .aggregatorError)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorServerError() {
        let errorJSON = errorJSONNamed("error_server")
        
        let error = APIError(statusCode: 504, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.ServerError"))
        XCTAssertEqual(error.statusCode, 504)
        XCTAssertEqual(error.type, .serverError)
        XCTAssertEqual(error.errorCode, .unknownServer)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorInternalException() {
        let errorJSON = errorJSONNamed("error_internal_exception")
        
        let error = APIError(statusCode: 500, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.ServerError"))
        XCTAssertEqual(error.statusCode, 500)
        XCTAssertEqual(error.type, .serverError)
        XCTAssertEqual(error.errorCode, .internalException)
        XCTAssertNotNil(error.message)
    }
    
    // MARK: - Status Code Only Tests
    
    func testAPIErrorUnknownAuth() {
        let error = APIError(statusCode: 401, response: nil)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.UnknownAuthorisation"))
        XCTAssertEqual(error.statusCode, 401)
        XCTAssertEqual(error.type, .otherAuthorisation)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.message)
    }
    
    func testAPIErrorMaintenance() {
        let error = APIError(statusCode: 502, response: nil)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.Maintenance"))
        XCTAssertEqual(error.statusCode, 502)
        XCTAssertEqual(error.type, .maintenance)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.message)
    }
    
    func testAPIErrorNotImplemented() {
        let error = APIError(statusCode: 501, response: nil)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.NotImplemented"))
        XCTAssertEqual(error.statusCode, 501)
        XCTAssertEqual(error.type, .notImplemented)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.message)
    }
    
    func testAPIErrorRateLimited() {
        let error = APIError(statusCode: 429, response: nil)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.RateLimit"))
        XCTAssertEqual(error.statusCode, 429)
        XCTAssertEqual(error.type, .rateLimit)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.message)
    }
    
    func testAPIErrorDeprecated() {
        let error = APIError(statusCode: 410, response: nil)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.DeprecatedError"))
        XCTAssertEqual(error.statusCode, 410)
        XCTAssertEqual(error.type, .deprecated)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.message)
    }
    
    func testAPIErrorMigrationFailed() {
        let errorJSON = errorJSONNamed("error_migration_failed")
        
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.MigrationFailed"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .migrationFailed)
        XCTAssertEqual(error.errorCode, .migrationFailed)
        XCTAssertNotNil(error.message)
    }
    
    // MARK: - Test Edge Cases
    
    func testAPIErrorBadFormat() {
        let errorJSON = errorJSONNamed("error_bad_format")
        
        let error = APIError(statusCode: 302, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.UnknownError"))
        XCTAssertEqual(error.statusCode, 302)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertNil(error.message)
    }
    
    func testAPIErrorUnknownCode() {
        let errorJSON = errorJSONNamed("error_unknown_code")
        
        let error = APIError(statusCode: 302, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.UnknownError"))
        XCTAssertEqual(error.statusCode, 302)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertNotNil(error.message)
    }
    
    func testAPIErrorMissingCode() {
        let errorJSON = errorJSONNamed("error_missing_code")
        
        let error = APIError(statusCode: 302, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.UnknownError"))
        XCTAssertEqual(error.statusCode, 302)
        XCTAssertEqual(error.type, .unknown)
        XCTAssertNil(error.errorCode)
        XCTAssertNotNil(error.message)
    }
    
    func testDebugDescription() {
        let errorJSON = errorJSONNamed("error_suspended_user")
        
        let error = APIError(statusCode: 401, response: errorJSON)
        XCTAssertNotEqual(error.localizedDescription, error.debugDescription)
        XCTAssertGreaterThan(error.debugDescription.count, error.localizedDescription.count)
        XCTAssertTrue(error.debugDescription.contains("F0112"))
    }
    
    // MARK: - Payment Errors
    
    func testAPIErrorPaymentAccountRestricted() {
        validatePaymentErrors(resourceFileName: "error_payment_account_restricted", errorCode: .paymentAccountRestricted)
    }
    
    func testAPIErrorPaymentInsufficientFunds() {
        validatePaymentErrors(resourceFileName: "error_payment_insufficient_funds", errorCode: .paymentInsufficientFunds)
    }
    
    func testAPIErrorPaymentInvalidAccount() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_account", errorCode: .paymentInvalidAccount)
    }
    
    func testAPIErrorPaymentInvalidBillerCode() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_biller_code", errorCode: .paymentInvalidBillerCode)
    }
    
    func testAPIErrorPaymentInvalidBpay() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_bpay", errorCode: .paymentInvalidBpay)
    }
    
    func testAPIErrorPaymentInvalidBSB() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_bsb", errorCode: .paymentInvalidBSB)
    }
    
    func testAPIErrorPaymentInvalidCRN() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_crn", errorCode: .paymentInvalidCRN)
    }
    
    func testAPIErrorPaymentInvalidDate() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_date", errorCode: .paymentInvalidDate)
    }
    
    func testAPIErrorPaymentInvalidDestinationAccount() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_destination_account", errorCode: .paymentInvalidDestinationAccount)
    }
    
    func testAPIErrorPaymentInvalidPayAnyone() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_pay_anyone", errorCode: .paymentInvalidPayAnyone)
    }
    
    func testAPIErrorPaymentInvalidSourceAccount() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_source_account", errorCode: .paymentInvalidSourceAccount)
    }
    
    func testAPIErrorPaymentInvalidTransfer() {
        validatePaymentErrors(resourceFileName: "error_payment_invalid_transfer", errorCode: .paymentInvalidTransfer)
    }
    
    func testAPIErrorPaymentOther() {
        validatePaymentErrors(resourceFileName: "error_payment_other", errorCode: .paymentOtherError)
    }
    
    func testAPIErrorPaymentProcessorConnectivity() {
        validatePaymentErrors(resourceFileName: "error_payment_processor_connectivity", errorCode: .paymentProcessorConnectivityError)
    }
    
    func testAPIErrorPaymentProcessor() {
        validatePaymentErrors(resourceFileName: "error_payment_processor", errorCode: .paymentProcessorError)
    }
    
    func validatePaymentErrors(resourceFileName: String, errorCode: APIErrorCode) {
        let errorJSON = errorJSONNamed(resourceFileName)
        let error = APIError(statusCode: 400, response: errorJSON)
        XCTAssertEqual(error.localizedDescription, Localization.string("Error.API.BadRequest"))
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.type, .badRequest)
        XCTAssertEqual(error.errorCode, errorCode)
        XCTAssertNotNil(error.message)
    }
    
}
