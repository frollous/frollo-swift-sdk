//
//  FileLogger.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import os

class FileLogger: Logger {
    
    static var exceptionHandler: (@convention(c) (NSException) -> Void)?
    
    private var fileHandle: FileHandle?
    private let logFilePath: URL
    private let previousLogFilePath: URL
    
    init(path: URL, previousPath: URL) {
        logFilePath = path
        previousLogFilePath = previousPath
        
        let folderPath = path.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            do {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log("Log container folder couldn't be created: %@", error.localizedDescription)
            }
        }
        
        rotateLogFile()
        
        openFile()
    }
    
    deinit {
        closeFile()
    }
    
    func writeMessage(_ message: String, level: LogLevel) {
        guard let handle = fileHandle
            else {
            return
        }
        
        startHandlingExceptions()
        
        if let data = message.appending("\n").data(using: .utf8) {
            handle.write(data)
        }
        
        stopHandlingExceptions()
    }
    
    private func openFile() {
        FileManager.default.createFile(atPath: logFilePath.path, contents: nil, attributes: nil)
        
        do {
            try fileHandle = FileHandle(forWritingTo: logFilePath)
        } catch let error {
            os_log("Failed to open path for writing log file: %@", error.localizedDescription)
        }
    }
    
    private func closeFile() {
        guard let handle = fileHandle
            else {
                return
        }
        
        handle.closeFile()
        fileHandle = nil
    }
    
    private func rotateLogFile() {
        if FileManager.default.fileExists(atPath: logFilePath.path) {
            // Delete the old log file
            if FileManager.default.fileExists(atPath: previousLogFilePath.path) {
                do {
                    try FileManager.default.removeItem(at: previousLogFilePath)
                } catch let error {
                    os_log("Error removing previous log file %@", error.localizedDescription)
                }
            }
            
            // Move the old one
            do {
                try FileManager.default.moveItem(at: logFilePath, to: previousLogFilePath)
            } catch let error {
                os_log("Failed to rotate log files, nuking: %@", error.localizedDescription)
                
                try? FileManager.default.removeItem(at: logFilePath)
            }
        }
    }
    
    private func startHandlingExceptions() {
        FileLogger.exceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler({ exception in
            os_log("exception: %@)", exception)
            FileLogger.exceptionHandler?(exception)
        })
    }
    
    private func stopHandlingExceptions() {
        NSSetUncaughtExceptionHandler(FileLogger.exceptionHandler)
        FileLogger.exceptionHandler = nil
    }
    
}
