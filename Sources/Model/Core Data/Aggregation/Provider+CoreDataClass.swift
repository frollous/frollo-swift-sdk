//
//  Provider+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Provider)
public class Provider: NSManagedObject {
    
    public enum AuthType: String, Codable {
        case credentials
        case mfaCredentials = "mfa_credentials"
        case oAuth = "oauth"
    }
    
    public enum EncryptionType: String, Codable {
        case unsupported
        case encryptValues = "encrypt_values"
    }
    
    public enum MFAType: String, Codable {
        case image
        case question
        case strongMultiple = "strong_multiple"
        case token
    }

    public enum Status: String, Codable {
        case beta
        case disabled
        case supported
        case unsupported
    }
    
    static let entityName = "Provider"
    
    public var authType: AuthType? {
        get {
            if let rawValue = authTypeRawValue {
                return AuthType(rawValue: rawValue)!
            }
            return nil
        }
        set {
            authTypeRawValue = newValue?.rawValue
        }
    }
    
    public var encryptionType: EncryptionType? {
        get {
            if let rawValue = encryptionTypeRawValue {
                return EncryptionType(rawValue: rawValue)
            }
            return nil
        }
        set {
            encryptionTypeRawValue = newValue?.rawValue
        }
    }
    public var forgotPasswordURL: URL? {
        get {
            if let urlString = forgotPasswordURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            forgotPasswordURLString = newValue?.absoluteString
        }
    }
    
    public var largeLogoURL: URL? {
        get {
            if let urlString = largeLogoURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            largeLogoURLString = newValue?.absoluteString
        }
    }
    
    public var loginURL: URL? {
        get {
            if let urlString = loginURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            loginURLString = newValue?.absoluteString
        }
    }
    
    public var mfaType: MFAType? {
        get {
            if let rawValue = mfaTypeRawValue {
                return MFAType(rawValue: rawValue)
            }
            return nil
        }
        set {
            mfaTypeRawValue = newValue?.rawValue
        }
    }
    
    public var smallLogoURL: URL? {
        get {
            if let urlString = smallLogoURLString {
                return URL(string: urlString)
            }
            return nil
        }
        set {
            smallLogoURLString = newValue?.absoluteString
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue!)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    internal func update(response: APIProviderResponse) {
        providerID = response.id
        name = response.name
        popular = response.popular
        smallLogoURLString = response.smallLogoURLString
        status = response.status
        
        // Reset all containers
        containerBank = false
        containerBill = false
        containerCreditCard = false
        containerCreditScore = false
        containerInsurance = false
        containerInvestment = false
        containerLoan = false
        containerRealEstate = false
        containerReward = false
        containerUnknown = false
        
        for containerName in response.containerNames {
            switch containerName {
                case .bank:
                    containerBank = true
                case .bill:
                    containerBill = true
                case .creditCard:
                    containerCreditCard = true
                case .creditScore:
                    containerCreditScore = true
                case .insurance:
                    containerInsurance = true
                case .investment:
                    containerInvestment = true
                case .loan:
                    containerLoan = true
                case .realEstate:
                    containerRealEstate = true
                case .reward:
                    containerReward = true
                case .unknown:
                    containerUnknown = true
            }
        }
        
        // Optional fields only returned on individual API, only update if present
        if let responseAuthType = response.authType {
            authType = responseAuthType
        }
        if let responseBaseURL = response.baseURLString {
            baseURLString = responseBaseURL
        }
        if let responseEncryption = response.encryption {
            encryptionType = responseEncryption.encryptionType
            encryptionAlias = responseEncryption.alias
            encryptionPublicKey = responseEncryption.pem
        }
        if let responseForgotPasswordURL = response.forgotPasswordURLString {
            forgotPasswordURLString = responseForgotPasswordURL
        }
        if let responseHelpMessage = response.helpMessage {
            helpMessage = responseHelpMessage
        }
        if let responseLargeLogoURL = response.largeLogoURLString {
            largeLogoURLString = responseLargeLogoURL
        }
        if let responseLoginMessage = response.loginHelpMessage {
            loginHelpMessage = responseLoginMessage
        }
        if let responseLoginURL = response.loginURLString {
            loginURLString = responseLoginURL
        }
        if let responseMFAType = response.mfaType {
            mfaType = responseMFAType
        }
        if let responseOAuthSite = response.oAuthSite {
            oAuthSite = responseOAuthSite
        }
        if let responseSmallURL = response.smallLogoURLString {
            smallLogoURLString = responseSmallURL
        }
        
    }
    
}
