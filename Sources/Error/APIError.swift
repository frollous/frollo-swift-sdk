//
//  APIError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class APIError: FrolloSDKError {
    
    enum APIErrorType {
        case deprecated
        
        case maintenance
        case notImplemented
        case rateLimit
        case serverError
        
        case badRequest
        case unauthorised
        case notFound
        case alreadyExists
        case invalidData
        
        case invalidAccessToken
        case invalidRefreshToken
        case invalidUsernamePassword
        case suspendedDevice
        case suspendedUser
        case otherAuthorisation
        
        case unknown
    }
    
    enum APIErrorCode: String {
        case deprecated = "D0001"
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
    }
    
    public var debugDescription: String {
        get {
            
        }
    }
    public var localizedDescription: String {
        get {
            
        }
    }
    
    internal var type: APIErrorType
    internal var statusCode: Int?
    
    init(statusCode: Int?, response: [String: Any]?) {
        
    }
    
    // MARK: - Descriptions
    
    private func localizedAPIErrorDescription() {
        switch <#value#> {
        case <#pattern#>:
            <#code#>
        default:
            <#code#>
        }
    }
    
}
