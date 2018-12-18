//
//  APIErrorResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
    
    /// F0200 - Unauthorised
    case unauthorised = "F0200"
    
    /// F0300 - Not Found
    case notFound = "F0300"
    
    /// F0400 - Already Exists
    case alreadyExists = "F0400"
    
    /// F9000 - Aggregator Error
    case aggregatorError = "F9000"
    
    /// F9998 - Unknown Server Error
    case unknownServer = "F9998"
    
    /// F9999 - Internal Exception
    case internalException = "F9999"
    
}

internal struct APIErrorResponse: Codable {
    
    internal struct ErrorBody: Codable {
        
        enum CodingKeys: String, CodingKey {
            case errorCode = "error_code"
            case errorMessage = "error_message"
        }
        
        let errorCode: APIErrorCode
        let errorMessage: String
        
    }
    
    internal let error: ErrorBody
    
}
