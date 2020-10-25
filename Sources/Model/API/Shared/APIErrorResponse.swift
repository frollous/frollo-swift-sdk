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

/**
 API Error Code
 
 Frollo API Error Codes
 */
public enum APIErrorCode: String, Codable {
    
    /// F0001 - Invalid Value
    case invalidValue = "F0001"
    
    /// F0002 - Invalid Length
    case invalidLength = "F0002"
    
    /// F0003 - Invalid Authorisation Header
    case invalidAuthorisationHeader = "F0003"
    
    /// F0004 - Invalid User Agent Header
    case invalidUserAgentHeader = "F0004"
    
    /// F0005 - Invalid Must Be Different
    case invalidMustBeDifferent = "F0005"
    
    /// F0006 - Invalid Over Limit
    case invalidOverLimit = "F0006"
    
    /// F0007 - Invalid Count
    case invalidCount = "F0007"
    
    /// F0012 - Migration Failed
    case migrationFailed = "F0012"
    
    /// F0014 - Aggregator Bad Request Received
    case aggregatorBadRequest = "F0014"
    
    /// F0101 - Invalid Access Token
    case invalidAccessToken = "F0101"
    
    /// F0110 - Invalid Refresh Token
    case invalidRefreshToken = "F0110"
    
    /// F0111 - Invalid Username Password
    case invalidUsernamePassword = "F0111"
    
    /// F0112 - Suspended User
    case suspendedUser = "F0112"
    
    /// F0113 - Suspended Device
    case suspendedDevice = "F0113"
    
    /// F0114 - Account Locked
    case accountLocked = "F0114"
    
    /// F0200 - Unauthorised
    case unauthorised = "F0200"
    
    /// F0300 - Not Found
    case notFound = "F0300"
    
    /// F0400 - Already Exists
    case alreadyExists = "F0400"
    
    ///  Payment - Other error
    case paymentOtherError = "F1000"
    
    ///  Payment - Payment processor error
    case paymentProcessorError = "F1001"
    
    ///  Payment - Payment processor connectivity
    case paymentProcessorConnectivityError = "F1002"
    
    ///  Payment validation - Insufficient funds
    case paymentInsufficientFunds = "F1010"
    
    ///  Payment validation - Invalid date
    case paymentInvalidDate = "F1011"
    
    ///  Payment validation - Invalid source account
    case paymentInvalidSourceAccount = "F1012"
    
    ///  Payment validation - Invalid destination account
    case paymentInvalidDestinationAccount = "F1013"
    
    ///  Payment validation - Account restricted
    case paymentAccountRestricted = "F1014"
    
    ///  Payment validation - BPAY Other
    case paymentInvalidBpay = "F1020"
    
    ///  Payment validation - BPAY Biller Code
    case paymentInvalidBillerCode = "F1021"
    
    ///  Payment validation - BPAY CRN
    case paymentInvalidCRN = "F1022"
    
    ///  Payment validation - Pay Anyone Other
    case paymentInvalidPayAnyone = "F1030"
    
    ///  Payment validation - Pay Anyone BSB
    case paymentInvalidBSB = "F1031"
    
    ///  Payment validation - Pay Anyone Account Name or Number
    case paymentInvalidAccount = "F1032"
    
    ///  Transfer validation - Other
    case paymentInvalidTransfer = "F1040"
    
    /// F9000 - Aggregator Error
    case aggregatorError = "F9000"
    
    /// F9998 - Unknown Server Error
    case unknownServer = "F9998"
    
    /// F9999 - Internal Exception
    case internalException = "F9999"
    
    /// F0120 - OTP is required for completing payment
    case missingOTP = "F0120"
    
    /// F0117 - OTP is invalid
    case invalidOTP = "F0117"
}

internal struct APIErrorResponse: Codable {
    
    internal struct ErrorBody: Codable {
        
        enum CodingKeys: String, CodingKey {
            case errorCodeRawValue = "error_code"
            case errorMessage = "error_message"
        }
        
        let errorCodeRawValue: String?
        let errorMessage: String
        
    }
    
    internal let error: ErrorBody
    
}

extension APIErrorResponse.ErrorBody {
    
    internal var errorCode: APIErrorCode? {
        if let rawValue = errorCodeRawValue {
            return APIErrorCode(rawValue: rawValue)
        }
        return nil
    }
    
}
