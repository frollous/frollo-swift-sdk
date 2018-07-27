//
//  APIErrorResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 6/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIErrorResponse: Codable {
    
    enum APIErrorCode: String, Codable {
        case invalidValue = "F0001"
        case invalidLength = "F0002"
        case invalidAuthorisationHeader = "F0003"
        case invalidUserAgentHeader = "F0004"
        case invalidMustBeDifferent = "F0005"
        case invalidOverLimit = "F0006"
        case invalidCount = "F0007"
        case invalidAccessToken = "F0101"
        case invalidRefreshToken = "F0110"
        case invalidUsernamePassword = "F0111"
        case suspendedUser = "F0112"
        case suspendedDevice = "F0113"
        case unauthorised = "F0200"
        case notFound = "F0300"
        case alreadyExists = "F0400"
        case aggregatorError = "F9000"
        case unknownServer = "F9998"
        case internalException = "F9999"
    }
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
    
    let errorCode: APIErrorCode
    let errorMessage: String
    
}
