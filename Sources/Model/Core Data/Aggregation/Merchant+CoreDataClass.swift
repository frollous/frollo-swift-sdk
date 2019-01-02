//
//  Merchant+CoreDataClass.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//
//

import Foundation
import CoreData

/**
 Merchant
 
 Core Data representation of a merchant object
 */
public class Merchant: NSManagedObject, CacheableManagedObject {

    /**
     Merchant Type
     
     The type of merchant so non-retail ones can be identified
    */
    public enum MerchantType: String, Codable {
        
        /// Retailer
        case retailer
        
        /// Transactional
        case transactional
        
        /// Unknown
        case unknown
    }
    
    /// Core Data entity description name
    static var entityName = "Merchant"
    
    internal var primaryID: Int64 {
        get {
            return merchantID
        }
    }
    
    internal var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    /// Type of merchant
    public var merchantType: MerchantType {
        get {
            return MerchantType(rawValue: merchantTypeRawValue!)!
        }
        set {
            merchantTypeRawValue = newValue.rawValue
        }
    }
    
    /// URL of the merchant's small logo image
    public var smallLogoURL: URL? {
        get {
            if let logoURL = smallLogoURLString {
                return URL(string: logoURL)
            }
            return nil
        }
        set {
            smallLogoURLString = newValue?.absoluteString
        }
    }
    
    // MARK: - Update Object
    
    internal func linkObject(object: CacheableManagedObject) {
        if let bill = object as? Bill {
            addToBills(bill)
        }
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let merchantResponse = response as? APIMerchantResponse {
            update(response: merchantResponse, context: context)
        }
    }
    
    internal func update(response: APIMerchantResponse, context: NSManagedObjectContext) {
        merchantID = response.id
        name = response.name
        merchantType = response.merchantType
        smallLogoURLString = response.smallLogoURL
    }
    
}
