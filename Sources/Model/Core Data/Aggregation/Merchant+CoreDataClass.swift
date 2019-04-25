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

/**
 Merchant
 
 Core Data representation of a merchant object
 */
public class Merchant: NSManagedObject, UniqueManagedObject {
    
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
    
    internal static var primaryKey = #keyPath(Merchant.merchantID)
    
    internal var primaryID: Int64 {
        return merchantID
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
    
    internal func linkObject(object: NSManagedObject) {
        if let bill = object as? Bill {
            addToBills(bill)
        }
        if let transaction = object as? Transaction {
            addToTransactions(transaction)
        }
        if let currentReport = object as? ReportTransactionCurrent {
            addToCurrentReports(currentReport)
        }
        if let historyReport = object as? ReportTransactionHistory {
            addToHistoryReports(historyReport)
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
