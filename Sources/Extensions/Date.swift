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

import Foundation

extension Date {
    
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.autoupdatingCurrent
        return calendar
    }()
    
    internal func startOfMonth() -> Date {
        let interval = Date.calendar.dateInterval(of: .month, for: self)!
        return interval.start
    }
    
    internal func startOfLastMonth() -> Date {
        let lastMonth = Date.calendar.date(byAdding: .month, value: -1, to: self)!
        let components = Date.calendar.dateComponents([.year, .month], from: lastMonth)
        return Date.calendar.date(from: components)!
    }
    
    internal func endOfMonth() -> Date {
        let interval = Date.calendar.dateInterval(of: .month, for: self)!
        return interval.end
    }
    
}
