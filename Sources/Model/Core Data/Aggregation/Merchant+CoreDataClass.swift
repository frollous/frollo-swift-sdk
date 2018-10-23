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

public class Merchant: NSManagedObject, CacheableManagedObject {

    public enum MerchantType: String, Codable {
        case retailer
        case transactional
        case unknown
    }
    
    static var entityName = "Merchant"
    
    var primaryID: Int64 {
        get {
            return merchantID
        }
    }
    
    var linkedID: Int64? {
        get {
            return nil
        }
    }
    
    public var merchantType: MerchantType {
        get {
            return MerchantType(rawValue: merchantTypeRawValue!)!
        }
        set {
            merchantTypeRawValue = newValue.rawValue
        }
    }
    
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
    
    func linkObject(object: CacheableManagedObject) {
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
    }
    
    func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let merchantResponse = response as? APIMerchantResponse {
            update(response: merchantResponse, context: context)
        }
    }
    
    func update(response: APIMerchantResponse, context: NSManagedObjectContext) {
        merchantID = response.id
        name = response.name
        merchantType = response.merchantType
        smallLogoURLString = response.smallLogoURL
    }
    
}
