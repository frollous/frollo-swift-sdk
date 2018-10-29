//
//  Log.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

internal protocol Logger: class {
    
    func writeMessage(_ message: String, level: LogLevel)
    
}

/// Logging level
public enum LogLevel: String, Codable {
    case debug
    case error
    case fault
    case info
}

class Log {
    
    static internal let manager = Log(synchronous: false)
    
    struct LogConstants {
        static let fileName = Bundle(for: Log.self).bundleIdentifier!
        static let logExtension = "log"
        static let previousFileSuffix = "-previous"
    }
    
    public static var logLevel: LogLevel = .error {
        didSet {
            manager.updateLogLevel()
        }
    }
    
    private let async: Bool
    private let lock = NSLock()
    private let queue = DispatchQueue(label: "Logging", qos: .utility)
    
    private let logFilePath: URL = {
        var logFileURL = FrolloSDK.dataFolderURL.appendingPathComponent(LogConstants.fileName)
        logFileURL.appendPathExtension(LogConstants.logExtension)
        return logFileURL
    }()
    
    private let previousLogFilePath: URL = {
        var logFileURL = FrolloSDK.dataFolderURL
        let fileName = LogConstants.fileName.appending(LogConstants.previousFileSuffix)
        logFileURL.appendPathComponent(fileName)
        logFileURL.appendPathExtension(LogConstants.logExtension)
        return logFileURL
    }()
    
    internal var debugLoggers = [Logger]()
    internal var errorLoggers = [Logger]()
    internal var faultLoggers = [Logger]()
    internal var infoLoggers = [Logger]()
    internal var network: Network?
    
    internal init(synchronous: Bool) {
        async = !synchronous
    }
    
    // MARK: - Log Level Setup
    
    private func updateLogLevel() {
        let consoleLogger = ConsoleLogger()
        let fileLogger = FileLogger(path: logFilePath, previousPath: previousLogFilePath)
        let networkLogger = NetworkLogger(network: network)
        
        debugLoggers = []
        infoLoggers = []
        errorLoggers = [fileLogger]
        faultLoggers = [fileLogger, networkLogger]
        
        switch Log.logLevel {
            case .debug:
                debugLoggers = [consoleLogger]
                fallthrough
            case .info:
                infoLoggers = [consoleLogger]
                fallthrough
            case .error:
                errorLoggers = [consoleLogger, fileLogger]
                fallthrough
            case .fault:
                faultLoggers = [consoleLogger, fileLogger, networkLogger]
        
        }
    }
    
    // MARK: - Log Messages
    
    class internal func error(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        manager.errorLog(String(format: "%@.%@[%ld]: %@", className(filePath: file), function, line, message))
    }
    
    class internal func fault(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        manager.faultLog(String(format: "%@.%@[%ld]: %@", className(filePath: file), function, line, message))
    }
    
    class internal func info(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        manager.infoLog(String(format: "%@.%@[%ld]: %@", className(filePath: file), function, line, message))
    }
    
    class internal func debug(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        manager.debugLog(String(format: "%@.%@[%ld]: %@", className(filePath: file), function, line, message))
    }
    
    internal func debugLog(_ message: String) {
        for logger in debugLoggers {
            if async {
                queue.async {
                    logger.writeMessage(message, level: .debug)
                }
            } else {
                lock.lock()
                logger.writeMessage(message, level: .debug)
                lock.unlock()
            }
        }
    }
    
    internal func infoLog(_ message: String) {
        for logger in infoLoggers {
            if async {
                queue.async {
                    logger.writeMessage(message, level: .info)
                }
            } else {
                lock.lock()
                logger.writeMessage(message, level: .info)
                lock.unlock()
            }
        }
    }
    
    internal func errorLog(_ message: String) {
        for logger in errorLoggers {
            if async {
                queue.async {
                    logger.writeMessage(message, level: .error)
                }
            } else {
                lock.lock()
                logger.writeMessage(message, level: .error)
                lock.unlock()
            }
        }
    }
    
    internal func faultLog(_ message: String) {
        for logger in faultLoggers {
            if async {
                queue.async {
                    logger.writeMessage(message, level: .fault)
                }
            } else {
                lock.lock()
                logger.writeMessage(message, level: .fault)
                lock.unlock()
            }
        }
    }
    
    class private func className(filePath: String) -> String {
        let path = filePath as NSString
        let className = path.lastPathComponent as NSString
        return className.deletingPathExtension
    }
    
}
