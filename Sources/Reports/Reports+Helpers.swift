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

extension Reports {
    
    /// Period - the time period the report is broken down to
    public enum Period: String, Codable, CaseIterable {
        
        /** Annually */
        case annually
        
        /** Biannually - twice in a year */
        case biannually
        
        /** Daily */
        case daily
        
        /** Fortnightly */
        case fortnightly
        
        /** Every four weeks */
        case fourWeekly = "four_weekly"
        
        /** Monthly */
        case monthly
        
        /** Quarterly */
        case quarterly
        
        /** Weekly */
        case weekly
        
    }
    
    /// Date formatter to convert daily date from stored date string to user's current locale
    public static let dailyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    /// Date formatter to convert monthly date from stored date string to user's current locale
    public static let monthlyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter
    }()
    
    /// Date formatter to convert weekly date from stored date string to user's current locale
    public static let weeklyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-W"
        return dateFormatter
    }()
    
}
