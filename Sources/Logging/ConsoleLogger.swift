//
//  ConsoleLogger.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import os

class ConsoleLogger: Logger {
    
    private let log: OSLog
    
    init() {
        log = OSLog(subsystem: Bundle(for: ConsoleLogger.self).bundleIdentifier!, category: "FrolloSDK")
    }
    
    func writeMessage(_ message: String, level: LogLevel) {
        switch level {
            case .debug:
                os_log("%@", log: log, type: .debug, message)
            case .info:
                os_log("%@", log: log, type: .info, message)
            case .error:
                os_log("%@", log: log, type: .error, message)
        }
    }
    
}
