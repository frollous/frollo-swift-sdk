//
//  VersionTests.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 10/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest
@testable import FrolloSDK

class VersionTests: XCTestCase {
    
    private let tempFolderPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(UUID().uuidString, isDirectory: true)
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.createDirectory(at: tempFolderPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        try? FileManager.default.removeItem(at: tempFolderPath)
    }
    
    // MARK: - Helpers
    
    private func setVersionEnvironment(path: URL, previousVersion: String, versionHistory: [String]) {
        let filePath = path.appendingPathComponent("FrolloSDKVersion").appendingPathExtension("plist")
        
        let persistence = PreferencesPersistence(path: filePath)
        persistence[VersionConstants.appVersionLast] = previousVersion
        persistence[VersionConstants.appVersionHistory] = versionHistory
        persistence.synchronise()
    }
    
    private func tempPath() -> URL {
        let path = tempFolderPath.appendingPathComponent(UUID().uuidString)
        
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        
        return path
    }
    
    // MARK: - Tests
    
    func testVersionFreshInstall() {
        let path = tempFolderPath
        
        let version = Version(path: path)
        
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        XCTAssertEqual(currentVersion, version.currentVersion)
        XCTAssertNil(version.previousVersion)
        XCTAssertFalse(version.versionHistory.count > 0)
    }
    
    func testVersionFreshInstallMigrationDoesNothing() {
        let path = tempFolderPath
        
        let version = Version(path: path)
        version.migrateVersion()
        XCTAssertNil(version.previousVersion)
    }
    
    func testVersioMigrationNotNeededOnFreshInstall() {
        let path = tempFolderPath
        
        let version = Version(path: path)
        let migrationNeeded = version.migrationNeeded()
        
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        XCTAssertFalse(migrationNeeded)
        XCTAssertEqual(currentVersion, version.previousVersion)
        XCTAssertTrue(version.versionHistory.contains(currentVersion))
    }
    
    func testVersionMigrationNotNeededIfVersionIsSame() {
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        
        let path = tempPath()
        setVersionEnvironment(path: path, previousVersion: currentVersion, versionHistory: [currentVersion])
        
        let suite = UserDefaults(suiteName: VersionConstants.suiteName)
        suite?.set(currentVersion, forKey: VersionConstants.appVersionLast)
        
        let version = Version(path: path)
        XCTAssertFalse(version.migrationNeeded())
    }
    
    func testVersionMigrationIfVersionIsOlder() {
        let oldVersion = "0.9.1"
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        
        let path = tempPath()
        setVersionEnvironment(path: path, previousVersion: oldVersion, versionHistory: [oldVersion])
        
        let version = Version(path: path)
        let migrationNeeded = version.migrationNeeded()
        
        XCTAssertTrue(migrationNeeded)
        
        version.migrateVersion()
        
        XCTAssertEqual(version.previousVersion, currentVersion)
        XCTAssertTrue(version.versionHistory.contains(currentVersion))
    }
    
}
