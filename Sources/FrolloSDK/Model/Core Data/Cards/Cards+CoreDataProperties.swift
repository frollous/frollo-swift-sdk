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

extension Card {
    
    /**
     Fetch Request
     
     - returns: Fetch request for `Card` type
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }
    
    /// Unique identifier of the card
    @NSManaged public var cardID: Int64
    
    /// ID of the account to which the card is associated with
    @NSManaged public var accountID: Int64
    
    /// Name of the card
    @NSManaged public var name: String?
    
    /// Nick name of the card (optional)
    @NSManaged public var nickName: String?
    
    /// The current status of the card; eg active, pending etc
    @NSManaged public var statusRawValue: String
    
    /// The design type of the card
    @NSManaged public var designTypeRawValue: String
    
    /// Date the card was created
    @NSManaged public var createdDate: Date
    
    /// Account associated with the card (Optional)
    @NSManaged public var account: Account?
    
    /// Date the card was cancelled (Optional)
    @NSManaged public var cancelledDate: Date?
    
    /// Name of the card holder (Optional)
    @NSManaged public var cardholderName: String?
    
    /// Date on which the card will expire (Optional).
    @NSManaged public var expiryDateString: String?
    
    /// Issuer of the card; eg Visa, Mastercard (Optional)
    @NSManaged public var issuerRawValue: String?
    
    /// Last 4 digits of the card's Primary Account Number (Optional)
    @NSManaged public var panLastDigits: String?
    
    /// Type of the card; eg credit, debit (Optional)
    @NSManaged public var typeRawValue: String?
    
    /// Date on which the PIN of card was set (Optional). Use only in predicates
    @NSManaged public var pinSetAtString: String?
}
