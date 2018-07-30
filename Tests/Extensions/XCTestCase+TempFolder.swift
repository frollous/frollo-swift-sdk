//
//  XCTestCase+TempFolder.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    internal func tempFolderPath() -> URL {
        var tempFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        tempFolder.appendPathComponent(UUID().uuidString, isDirectory: true)
        
        try? FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true, attributes: nil)
        
        return tempFolder
    }
    
}
