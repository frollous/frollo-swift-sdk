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
    
    enum AuthType: String, Codable {
        case credentials
        case mfaCredentials = "mfa_credentials"
        case oAuth = "oauth"
    }
    
    enum EncryptionType: String, Codable {
        case unsupported
        case values
    }
    
    enum MFAType: String, Codable {
        case image
        case question
        case strongMultiple = "strong_multiple"
        case token
    }

    enum Status: String, Codable {
        case beta
        case disabled
        case supported
        case unsupported
    }
    
    static let entityName = "Provider"
    
}
