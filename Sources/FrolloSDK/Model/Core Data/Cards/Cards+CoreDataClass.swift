//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreData
import Foundation
import SwiftyJSON

/**
 Card
 
 Core Data represenation of a Card
 */
public class Card: NSManagedObject, UniqueManagedObject {
    
    /// Core Data entity description name
    static var entityName = "Card"
    
    /**
     Card Status
     
     Status indicating the current state of the card.
     */
    public enum CardStatus: String, Codable, CaseIterable {
        /// The card is active
        case active
        
        /// The card is pending activation
        case pending
        
        /// The card is locked/ frozen
        case locked
    }
    
    /**
     Card Design Type
     
     Type indicating the design of the card
     */
    public enum CardDesignType: String, Codable, CaseIterable {
        /// Default design
        case `default`
    }
    
    /**
     Card Design Type
     
     Type indicating the issuer of the card
     */
    public enum CardIssuer: String, Codable, CaseIterable {
        /// Visa
        case visa
        
        /// Mastercard
        case mastercard
    }
    
    /**
     Card Type
     
     Indicates the type of the card
     */
    public enum CardType: String, Codable, CaseIterable {
        /// Credit
        case credit
        
        /// Debit
        case debit
        
        /// Prepaid
        case prepaid
    }
    
    internal static var primaryKey = #keyPath(Card.cardID)
    
    internal var primaryID: Int64 {
        return cardID
    }
    
    /// Indicates the current status of the card
    public var cardStatus: CardStatus {
        get {
            return CardStatus(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// The design type of the card
    public var cardDesignType: CardDesignType {
        get {
            return CardDesignType(rawValue: designTypeRawValue)!
        }
        set {
            designTypeRawValue = newValue.rawValue
        }
    }
    
    /// The design type of the card
    public var cardIssuer: CardIssuer? {
        get {
            guard let issuer = issuerRawValue else { return nil }
            
            return CardIssuer(rawValue: issuer)
        }
        set {
            issuerRawValue = newValue?.rawValue
        }
    }
    
    /// The design type of the card
    public var cardType: CardType? {
        get {
            guard let type = typeRawValue else { return nil }
            
            return CardType(rawValue: type)
        }
        set {
            typeRawValue = newValue?.rawValue
        }
    }
    
    // MARK: Updating Object
    
    internal func linkObject(object: NSManagedObject) {
        // Do nothing
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let cardsResponse = response as? APICardResponse {
            update(response: cardsResponse, context: context)
        }
    }
    
    internal func update(response: APICardResponse, context: NSManagedObjectContext) {
        cardID = response.id
        accountID = response.accountID
        cardStatus = response.status
        cardDesignType = response.designType
        createdDate = response.createdAt
        name = response.name
        nickName = response.nickName
        cancelledDate = response.cancelledAt
        typeRawValue = response.type
        panLastDigits = response.panLastDigits
        expiryDateString = response.expiryDate
        cardholderName = response.cardholderName
        issuerRawValue = response.issuer
        pinSetAt = response.pinSetAt
    }
    
}
