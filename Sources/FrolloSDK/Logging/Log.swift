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

internal protocol Logger: AnyObject {
    
    func writeMessage(_ message: String, level: LogLevel)
    
}

/// Logging level
public enum LogLevel: Int, Codable {
    
    /// Log all messages including verbose debug statements
    case debug = 1
    
    /// Log only the most significant errors
    case error = 16
    
    /// Log additional information
    case info = 2
    
    /// Log user feedback message
    case off = 0
}

class Log {
    
    internal static let manager = Log(synchronous: false)
    internal static var logDataFolderURL: URL = Frollo.defaultDataFolderURL
    
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
        var logFileURL = logDataFolderURL.appendingPathComponent(LogConstants.fileName)
        logFileURL.appendPathExtension(LogConstants.logExtension)
        return logFileURL
    }()
    
    private let previousLogFilePath: URL = {
        var logFileURL = logDataFolderURL
        let fileName = LogConstants.fileName.appending(LogConstants.previousFileSuffix)
        logFileURL.appendPathComponent(fileName)
        logFileURL.appendPathExtension(LogConstants.logExtension)
        return logFileURL
    }()
    
    internal var debugLoggers = [Logger]()
    internal var errorLoggers = [Logger]()
    internal var infoLoggers = [Logger]()
    internal var service: APIService?
    
    internal init(synchronous: Bool) {
        self.async = !synchronous
    }
    
    // MARK: - Log Level Setup
    
    private func updateLogLevel() {
        let consoleLogger = ConsoleLogger()
        let fileLogger = FileLogger(path: logFilePath, previousPath: previousLogFilePath)
        let networkLogger = NetworkLogger(service: service)
        
        debugLoggers = []
        infoLoggers = []
        errorLoggers = [fileLogger, networkLogger]
        
        switch Log.logLevel {
            case .debug:
                debugLoggers = [consoleLogger]
                fallthrough
            case .info:
                infoLoggers = [consoleLogger]
                fallthrough
            case .error:
                errorLoggers = [consoleLogger, fileLogger, networkLogger]
            case .off: break
        }
    }
    
    // MARK: - Log Messages
    
    internal class func error(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        manager.errorLog(String(format: "%@.%@[%ld]: %@", className(filePath: file), function, line, message))
    }
    
    internal class func info(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        manager.infoLog(String(format: "%@.%@[%ld]: %@", className(filePath: file), function, line, message))
    }
    
    internal class func debug(_ message: String, _ file: String = #file, _ function: String = #function, line: Int = #line) {
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
    
    private class func className(filePath: String) -> String {
        let path = filePath as NSString
        let className = path.lastPathComponent as NSString
        return className.deletingPathExtension
    }
    
}
