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

import Foundation

/// API Card Lock Or Replace Request
public struct APICardLockOrReplaceRequest: Codable {
    
    /// Reason for locking/ replacing the Card
    public enum CardLockOrReplaceReason: String, Codable, CaseIterable {
        /// Card Fraud
        case fraud
        
        /// Loss of Card
        case loss
        
        /// Stolen Card
        case stolen
        
        /// Damaged card
        case damage
        
        /// Non receipt of card
        case nonReceipt = "non_receipt"
    }
    
    let reason: CardLockOrReplaceReason?
}
