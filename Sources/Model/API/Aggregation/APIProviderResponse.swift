//
//  APIProviderResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIProviderResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case authType = "auth_type"
        case forgotPasswordURLString = "forget_password_url"
        case id
        case helpMessage = "help_message"
        case largeLogoURLString = "large_logo_url"
        case loginHelpMessage = "login_help_message"
        case mfaType = "mfa_type"
        case name
        case oAuthSite = "o_auth_site"
        case popular
        case smallLogoURLString = "small_logo_url"
        case status
    }
    
    struct Encryption: Codable {
        
        enum CodingKeys: String, CodingKey {
            case alias
            case encryptionType = "encryption_type"
            case pem
        }
        
        let encryptionType: Provider.EncryptionType?
        
        var alias: String?
        var pem: String?
    }
    
    let id: Int64
    let name: String
    let popular: Bool
    let status: Provider.Status
    
    var authType: Provider.AuthType?
    var encryption: Encryption?
    var forgotPasswordURLString: String?
    var helpMessage: String?
    var largeLogoURLString: String?
    var loginMessage: String?
    var loginHelpMessage: String?
    var mfaType: Provider.MFAType?
    var oAuthSite: Bool?
    var smallLogoURLString: String?
    
}
