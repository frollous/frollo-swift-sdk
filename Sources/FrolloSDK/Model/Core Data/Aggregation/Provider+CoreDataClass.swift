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
//

import CoreData
import Foundation
import SwiftyJSON

/**
 Provider
 
 Core Data represenation of provider of accounts
 */
public class Provider: NSManagedObject, UniqueManagedObject {
    
    internal var primaryID: Int64 {
        return providerID
    }
    
    /**
     Provider Authentication Type
     
     How the provider performs authentication.
     */
    public enum AuthType: String, Codable {
        
        /// Credentials. Using the user's login credentials
        case credentials
        
        /// MFA Credentials. Using the user's MFA and login credentials
        case mfaCredentials = "mfa_credentials"
        
        /// OAuth. Using OAuth2 authentication
        case oAuth = "oauth"
        
        /// Unknown
        case unknown
        
    }
    
    /**
     Provider Encryption Type
     
     The type of login form encryption supported by the provider if applicable
     */
    public enum EncryptionType: String, Codable {
        
        /// Unsupported
        case unsupported
        
        /// Encrypt Values. Encrypt the value field of the login form
        case encryptValues = "encrypt_values"
        
    }
    
    /**
     MFA Type
     
     Type of MFA the provider uses to authenticate
     */
    public enum MFAType: String, Codable {
        
        /// Image- usually a captcha
        case image
        
        /// Question. Security question and answer typically
        case question
        
        /// Strong Multiple. Multiple different types
        case strongMultiple = "strong_multiple"
        
        /// Token. Usually an OTP or RSA token
        case token
        
        /// Unknown
        case unknown
        
    }
    
    /**
     Provider Status
     
     Status of the support of the provider
     */
    public enum Status: String, Codable {
        
        /// Beta. Support is still being developed so may have some issues
        case beta
        
        /// Disabled. Provider has been disabled by the aggregator
        case disabled
        
        /// Supported. Provider is fully supported
        case supported
        
        /// Unsupported. Provider is no longer supported
        case unsupported
        
        /// Outage. The Provider is currently experiencing an outage.
        case outage
        
        /// Coming Soon. The Provider is coming soon, but cannot be linked when they are in this status.
        case comingSoon = "coming_soon"
        
    }
    
    /**
      Aggregator Type
     
     The aggregator used to authenticate and fetch transactions from provider
     */
    public enum AggregatorType: String, Codable {
        
        /// Yodlee aggregation platform
        case yodlee
        
        /// Direct API connection via the Consumer Data Right (Open Banking) regime
        case cdr
        
        /// Demo providers used for testing and demos
        case demo
        
        /// Unknown aggregator
        case unknown
    }
    
    /// Core Data entity description name
    static let entityName = "Provider"
    
    internal static var primaryKey = #keyPath(Provider.providerID)
    
    /// Authentication Type (optional)
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
    
    /// Encryption Type (optional)
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
    
    /// URL to the forgot password page of the provider (optional)
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
    
    /// URL to the large logo image of the provider (optional)
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
    
    /// Login Form (optional)
    public var loginForm: ProviderLoginForm? {
        get {
            if let rawValue = loginFormRawValue {
                let decoder = JSONDecoder()
                
                do {
                    return try decoder.decode(ProviderLoginForm.self, from: rawValue)
                } catch {
                    error.logError()
                }
            }
            return nil
        }
        set {
            if let newRawValue = newValue {
                let encoder = JSONEncoder()
                
                do {
                    loginFormRawValue = try encoder.encode(newRawValue)
                } catch {
                    loginFormRawValue = nil
                }
            } else {
                loginFormRawValue = nil
            }
        }
    }
    
    /// URL of the provider's login page (optional)
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
    
    /// Type of MFA on the provider (optional)
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
    
    /// URL to the small logo image (optional)
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
    
    /// Status of the provider
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Aggregator type on the provider
    public var aggregatorType: AggregatorType {
        get {
            return AggregatorType(rawValue: aggregatorTypeRawValue) ?? .yodlee
        }
        set {
            aggregatorTypeRawValue = newValue.rawValue
        }
    }
    
    /// The aggregator permissions ids on the provider.
    public var permissionIDs: [String] {
        get {
            guard let permissionIDsRawValue = permissionIDsRawValue else { return [] }
            do {
                let permissions = try JSONDecoder().decode([String].self, from: permissionIDsRawValue)
                return permissions
            } catch {
                error.logError()
                return []
            }
        }
        set {
            permissionIDsRawValue = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Relationships
    
    internal func linkObject(object: NSManagedObject) {
        if let providerAccount = object as? ProviderAccount {
            addToProviderAccounts(providerAccount)
        }
        if let consent = object as? Consent {
            addToConsents(consent)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let providerResponse = response as? APIProviderResponse {
            update(response: providerResponse, context: context)
        }
    }
    
    internal func update(response: APIProviderResponse, context: NSManagedObjectContext) {
        providerID = response.id
        name = response.name
        popular = response.popular
        smallLogoURLString = response.smallLogoURLString
        status = response.status
        aggregatorType = AggregatorType(rawValue: response.aggregatorType) ?? .unknown
        permissionIDs = response.permissionIDs
        productsAvailable = response.productsAvailable ?? false
        
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
        if let responseLoginForm = response.loginForm {
            loginForm = responseLoginForm
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
        if let responseLoginForm = response.loginForm {
            loginForm = responseLoginForm
        }
        
    }
    
}
