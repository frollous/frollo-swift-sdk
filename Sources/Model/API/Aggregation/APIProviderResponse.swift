//
//  APIProviderResponse.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct APIProviderResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case authType = "auth_type"
        case baseURLString = "base_url"
        case containerNames = "container_names"
        case encryption
        case forgotPasswordURLString = "forget_password_url"
        case helpMessage = "help_message"
        case id
        case largeLogoURLString = "large_logo_url"
        case loginHelpMessage = "login_help_message"
        case loginURLString = "login_url"
        case mfaType = "mfa_type"
        case name
        case oAuthSite = "o_auth_site"
        case popular
        case smallLogoURLString = "small_logo_url"
        case status
    }
    
    enum ContainerName: String, Codable {
        case bank
        case bill
        case creditCard = "credit_card"
        case creditScore = "credit_score"
        case insurance
        case investment
        case loan
        case realEstate = "real_estate"
        case reward
        case unknown
    }
    
    struct Encryption: Codable {
        
        enum CodingKeys: String, CodingKey {
            case alias
            case encryptionType = "encryption_type"
            case pem
        }
        
        let encryptionType: Provider.EncryptionType
        
        var alias: String?
        var pem: String?
    }
    
    var id: Int64
    let containerNames: [ContainerName]
    let name: String
    let popular: Bool
    let status: Provider.Status
    
    var authType: Provider.AuthType?
    var baseURLString: String?
    var encryption: Encryption?
    var forgotPasswordURLString: String?
    var helpMessage: String?
    var largeLogoURLString: String?
    var loginHelpMessage: String?
    var loginURLString: String?
    var mfaType: Provider.MFAType?
    var oAuthSite: Bool?
    var smallLogoURLString: String?
    
}
