//
//  APIUserLoginRequest.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 27/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIUserLoginRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case authType = "auth_type"
        case deviceID = "device_id"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case email
        case password
        case userID = "user_id"
        case userToken = "user_token"
    }
    
    /**
     Authentication Type
     
     The method to be used for authenticating the user when logging in.
    */
    enum AuthType: String, Codable {
        /**
         Email
         
         Authenticate with an email address and password
        */
        case email
        
        /**
         Facebook
         
         Authenticate using Facebook using the user's email, Facebook User ID and Facebook Access Token.
        */
        case facebook
        
        /**
         Volt
         
         Authenticate using a Volt token, requires email, Volt user ID and Volt access token.
        */
        case volt
    }
    
    let authType: AuthType
    let deviceID: String
    let deviceName: String
    let deviceType: String
    
    var email: String?
    var password: String?
    var userID: String? = nil
    var userToken: String? = nil
    
    var valid: Bool {
        get {
            switch authType {
                case .email:
                    return email != nil && password != nil
                case .facebook:
                    return email != nil && userID != nil && userToken != nil
                case .volt:
                    return userID != nil && userToken != nil
            }
        }
    }
    
}
