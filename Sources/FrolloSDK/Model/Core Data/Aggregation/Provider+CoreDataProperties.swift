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

extension Provider {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Provider` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Provider> {
        return NSFetchRequest<Provider>(entityName: "Provider")
    }
    
    /// Raw value of the authentication type. Use only in predicates (optional)
    @NSManaged public var authTypeRawValue: String?
    
    /// Raw value of the base URL of the provider's website. Use only in predicates (optional)
    @NSManaged public var baseURLString: String?
    
    /// Supports bank containers
    @NSManaged public var containerBank: Bool
    
    /// Supports bill containers
    @NSManaged public var containerBill: Bool
    
    /// Supports credit card containers
    @NSManaged public var containerCreditCard: Bool
    
    /// Supports credit score containers
    @NSManaged public var containerCreditScore: Bool
    
    /// Supports insurance containers
    @NSManaged public var containerInsurance: Bool
    
    /// Supports investment containers
    @NSManaged public var containerInvestment: Bool
    
    /// Supports loan containers
    @NSManaged public var containerLoan: Bool
    
    /// Supports real estate containers
    @NSManaged public var containerRealEstate: Bool
    
    /// Supports reward containers
    @NSManaged public var containerReward: Bool
    
    /// Supports unknown containers
    @NSManaged public var containerUnknown: Bool
    
    /// Encryption alias to be appended to login form values (optional)
    @NSManaged public var encryptionAlias: String?
    
    /// PEM Public key to be used to encrypt login forms (optional)
    @NSManaged public var encryptionPublicKey: String?
    
    /// Raw value for the encryption type supported. Use only in predicates (optional)
    @NSManaged public var encryptionTypeRawValue: String?
    
    /// Raw value for the forgot password URL. Use only in predicates (optional)
    @NSManaged public var forgotPasswordURLString: String?
    
    /// Help message to be displayed alongside the provider (optional)
    @NSManaged public var helpMessage: String?
    
    /// Raw value for the large logo URL. Use only in predicates (optional)
    @NSManaged public var largeLogoURLString: String?
    
    /// Raw value storing the login form. Do not use (optional)
    @NSManaged public var loginFormRawValue: Data?
    
    /// Login help message (optional)
    @NSManaged public var loginHelpMessage: String?
    
    /// Raw value of the login URL. Use only in predicates (optional)
    @NSManaged public var loginURLString: String?
    
    /// Raw value of the MFA type. Use only in predicates (optional)
    @NSManaged public var mfaTypeRawValue: String?
    
    /// Name of the provider
    @NSManaged public var name: String
    
    /// OAuth site
    @NSManaged public var oAuthSite: Bool
    
    /// Popular provider
    @NSManaged public var popular: Bool
    
    /// Unique ID of the provider
    @NSManaged public var providerID: Int64
    
    /// ProductsAvailable. True if CDR Products are available for this Provider
    @NSManaged public var productsAvailable: Bool
    
    /// Raw value of the small logo URL. Use only in predicates (optional)
    @NSManaged public var smallLogoURLString: String?
    
    /// Raw value of the status. Use only in predicate
    @NSManaged public var statusRawValue: String
    
    /// Raw value of the permission IDs array. Use only in predicate (Optional)
    @NSManaged public var permissionIDsRawValue: Data?
    
    /// Raw value of the aggregator type. Use only in predicate
    @NSManaged public var aggregatorTypeRawValue: String
    
    /// Child provider accounts
    @NSManaged public var providerAccounts: Set<ProviderAccount>?
    
    /// Child associated consents
    @NSManaged public var consents: Set<Consent>?
    
}

// MARK: Generated accessors for providerAccounts

extension Provider {
    
    /// Add a provider account relationship
    @objc(addProviderAccountsObject:)
    @NSManaged public func addToProviderAccounts(_ value: ProviderAccount)
    
    /// Remove a provider account relationship
    @objc(removeProviderAccountsObject:)
    @NSManaged public func removeFromProviderAccounts(_ value: ProviderAccount)
    
    /// Add provider account relationships
    @objc(addProviderAccounts:)
    @NSManaged public func addToProviderAccounts(_ values: Set<ProviderAccount>)
    
    /// Remove provider account relationships
    @objc(removeProviderAccounts:)
    @NSManaged public func removeFromProviderAccounts(_ values: Set<ProviderAccount>)
    
}

// MARK: Generated accessors for consents

extension Provider {
    
    /// Add a consent relationship
    @objc(addConsentsObject:)
    @NSManaged public func addToConsents(_ value: Consent)
    
    /// Remove a consent relationship
    @objc(removeConsentsObject:)
    @NSManaged public func removeFromConsents(_ value: Consent)
    
    /// Add consent relationships
    @objc(addConsents:)
    @NSManaged public func addToConsents(_ values: Set<Consent>)
    
    /// Remove consent relationships
    @objc(removeConsents:)
    @NSManaged public func removeFromConsents(_ values: Set<Consent>)
    
}
