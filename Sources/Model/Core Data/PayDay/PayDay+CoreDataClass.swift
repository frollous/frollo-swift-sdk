//
//  Copyright © 2018 Frollo. All rights reserved.
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
//

import CoreData
import Foundation

public class PayDay: NSManagedObject {
    
    /**
     Period
     
     How often a pay day occurs
     */
    public enum Period: String, Codable, CaseIterable {
        
        /// Fortnightly
        case fortnightly
        
        /// Every four weeks
        case fourWeekly = "four_weekly"
        
        /// Irregular
        case irregular
        
        /// Monthly
        case monthly
        
        /// Unknown
        case unknown
        
        /// Weekly
        case weekly
        
    }
    
    /**
     Status
     
     Status of the user's payday indicating how it has been determined
     */
    public enum Status: String, Codable, CaseIterable {
        
        /// Calculating - Pay day is being calculated from transaction history
        case calculating
        
        /// Confirmed - User has confirmed or pay day has been set manually
        case confirmed
        
        /// Estimated - Pay day has been calculated from transaction history
        case estimated
        
        #warning("Document me")
        /// Suspended
        case suspended
        
        /// Unknown
        case unknown
        
    }
    
    /// Core Data entity description name
    static var entityName = "Goal"
    
    /// Period
    public var period: Period {
        get {
            return Period(rawValue: periodRawValue)!
        }
        set {
            periodRawValue = newValue.rawValue
        }
    }
    
    /// Pay Day Status
    public var status: Status {
        get {
            return Status(rawValue: statusRawValue)!
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
}
