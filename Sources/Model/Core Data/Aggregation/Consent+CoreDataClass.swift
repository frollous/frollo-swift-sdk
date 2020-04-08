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
 Consent
 
 Core Data model of the account.
 */
public class Consent: NSManagedObject, UniqueManagedObject {
    
    /// Date formatter to convert from stored date string to user's current locale
    public static let consentDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    /**
     Provider permissions
     
     The permission groups that are supported by this Provider. For now, this is only returned for cdr type Providers, and it will always contain the following three values (as mandated by the CDR spec)
     */
    public enum Permission: String, Codable {
        
        /// Customer's name, occupation and contact details
        case customerDetails = "customer_details"
        
        /// Account name, balance and details
        case accountDetails = "account_details"
        
        /// Transaction details
        case transactionDetails = "transaction_details"
        
        /// Unknown permission
        case unknown
    }
    
    public enum Status: String, Codable {
        
        /// Consent is still pending
        case pending
        
        /// Consent is active
        case active
        
        /// Consent has expired
        case expired
        
        /// Consent has been withdrawn
        case withdrawn
        
        /// Unknown status
        case unknown
    }
    
    internal var primaryID: Int64 {
        return consentID
    }
    
    /// Core Data entity description name
    static var entityName = "Consent"
    
    internal static var primaryKey = #keyPath(Consent.consentID)
    
    /// Additional Permissions - custom JSON to be stored with the goal
    public var additionalPermissions: [String: Bool]? {
        get {
            if let rawValue = additionalPermissionsRawValue {
                do {
                    return try JSONSerialization.jsonObject(with: rawValue, options: []) as? [String: Bool]
                } catch {
                    Log.error(error.localizedDescription)
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                do {
                    additionalPermissionsRawValue = try JSONSerialization.data(withJSONObject: newValue, options: [])
                } catch {
                    Log.error(error.localizedDescription)
                    additionalPermissionsRawValue = nil
                }
            } else {
                additionalPermissionsRawValue = nil
            }
        }
    }
    
    /// The permissions on the consent
    public var permissions: [Permission] {
        get {
            let permissionStrings = permissionsRawValue.components(separatedBy: "|")
            return permissionStrings.map { Consent.Permission(rawValue: $0) }.compactMap { $0 }
        }
        set {
            let newString = newValue.map { $0.rawValue }.joined(separator: "|")
            permissionsRawValue = "|" + newString + "|"
        }
    }
    
    /// The status of the consent
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue) ?? .unknown
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// The sharing duration (in seconds) of the consent
    public var sharingDuration: Int64? {
        get {
            if sharingDurationRawValue == -1 {
                return nil
            } else {
                return sharingDurationRawValue
            }
        }
        set {
            if let newValue = newValue {
                sharingDurationRawValue = newValue
            } else {
                sharingDurationRawValue = -1
            }
        }
    }
    
    public var authorizationURL: URL? {
        get {
            guard let url = authorizationURLString else { return nil }
            return URL(string: url)
        }
        set {
            authorizationURLString = newValue?.absoluteString
        }
    }
    
    public var confirmationPDFURL: URL? {
        get {
            guard let url = confirmationPDFURLString else { return nil }
            return URL(string: url)
        }
        set {
            confirmationPDFURLString = newValue?.absoluteString
        }
    }
    
    public var withdrawalPDFURL: URL? {
        get {
            guard let url = withdrawalPDFURLString else { return nil }
            return URL(string: url)
        }
        set {
            withdrawalPDFURLString = newValue?.absoluteString
        }
    }
    
    public var sharingStartedAt: Date? {
        get {
            guard let startedAt = sharingStartedAtRawValue else { return nil }
            return Consent.consentDateFormatter.date(from: startedAt)
        }
        set {
            if let newValue = newValue {
                sharingStartedAtRawValue = Consent.consentDateFormatter.string(from: newValue)
            } else {
                sharingStartedAtRawValue = nil
            }
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let accountResponse = response as? APICDRConsentResponse {
            update(response: accountResponse, context: context)
        }
    }
    
    func linkObject(object: NSManagedObject) {}
    
    internal func update(response: APICDRConsentResponse, context: NSManagedObjectContext) {
        consentID = response.id
        providerID = response.providerID
        providerAccountID = response.providerAccountID ?? -1
        if let sharingStartedAt = response.sharingStartedAt {
            self.sharingStartedAt = Consent.consentDateFormatter.date(from: sharingStartedAt)
        } else {
            sharingStartedAt = nil
        }
        sharingDuration = response.sharingDuration
        permissions = response.permissions.map { Consent.Permission(rawValue: $0) }.compactMap { $0 }
        additionalPermissions = response.additionalPermissions
        status = Consent.Status(rawValue: response.status) ?? .unknown
        authorizationURL = response.authorisationRequestURL?.url
        confirmationPDFURL = response.confirmationPDFURL?.url
        withdrawalPDFURL = response.withdrawalPDFURL?.url
    }
}
