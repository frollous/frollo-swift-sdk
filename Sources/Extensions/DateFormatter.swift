//
//  DateFormatter.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 2/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var iso8601Milliseconds: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            return dateFormatter
        }
    }
    
}
