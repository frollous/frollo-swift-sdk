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
/**
 PaymentLimit
 
 Represents the Payment Limit
 */
public struct PaymentLimit: Codable {
    
    /**
     Payment Type
     
     Indicates the type of the Payment
     */
    public enum PaymentType: String, CaseIterable, Codable {
        
        /// transaction
        case transaction
        
        /// transfer
        case transfer
        
        /// npp
        case npp
        
        /// bpay
        case bpay
        
        /// pay anyone
        case payAnyone = "pay_anyone"
    }
    
    /**
     LimitPeriod
     
     Interval of payment limit
     */
    public enum LimitPeriod: String, Codable, CaseIterable {
        
        /// Annually
        case annually
        
        /// Biannually - twice in a year
        case biannually
        
        /// Daily
        case daily
        
        /// Fortnightly
        case fortnightly
        
        /// Every four weeks
        case fourWeekly = "four_weekly"
        
        /// Monthly
        case monthly
        
        /// Quarterly
        case quarterly
        
        /// Singular
        case singular
        
        /// Weekly
        case weekly
        
    }
    
    enum CodingKeys: String, CodingKey {
        case consumedAmount = "consumed_amount"
        case limitAmount = "limit_amount"
        case period
        case type
        
    }
    
    /// Type of the payment
    public let type: PaymentType
    
    /// Period of the limit
    public let period: LimitPeriod
    
    /// Limit Amount of the `period`
    public let limitAmount: String
    
    /// Consumed amount for the `period`
    public let consumedAmount: String?
    
}
