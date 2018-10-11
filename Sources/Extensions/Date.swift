//
//  Date.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 11/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
