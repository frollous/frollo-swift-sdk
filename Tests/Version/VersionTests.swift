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
    
    override func setUp() {
        super.setUp()
        
        // Remove the version suite
        UserDefaults.standard.removeSuite(named: VersionConstants.suiteName)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func setVersionEnvironment(previousVersion: String, versionHistory: [String]) {
        UserDefaults.standard.removePersistentDomain(forName: VersionConstants.suiteName)
        
        let suite = UserDefaults(suiteName: VersionConstants.suiteName)
        suite?.set(previousVersion, forKey: VersionConstants.appVersionLast)
        suite?.set(versionHistory, forKey: VersionConstants.appVersionHistory)
        suite?.synchronize()
    }
    
    // MARK: - Tests
    
    func testVersionFreshInstall() {
        UserDefaults.standard.removePersistentDomain(forName: VersionConstants.suiteName)
        
        let version = Version()
        
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        XCTAssertEqual(currentVersion, version.currentVersion)
        XCTAssertNil(version.previousVersion)
        XCTAssertFalse(version.versionHistory.count > 0)
    }
    
    func testVersionFreshInstallMigrationDoesNothing() {
        UserDefaults.standard.removePersistentDomain(forName: VersionConstants.suiteName)
        
        let version = Version()
        version.migrateVersion()
        XCTAssertNil(version.previousVersion)
    }
    
    func testVersioMigrationNotNeededOnFreshInstall() {
        UserDefaults.standard.removePersistentDomain(forName: VersionConstants.suiteName)
        
        let version = Version()
        let migrationNeeded = version.migrationNeeded()
        
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        XCTAssertFalse(migrationNeeded)
        XCTAssertEqual(currentVersion, version.previousVersion)
        XCTAssertTrue(version.versionHistory.contains(currentVersion))
    }
    
    func testVersionMigrationNotNeededIfVersionIsSame() {
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        
        setVersionEnvironment(previousVersion: currentVersion, versionHistory: [currentVersion])
        
        let suite = UserDefaults(suiteName: VersionConstants.suiteName)
        suite?.set(currentVersion, forKey: VersionConstants.appVersionLast)
        
        let version = Version()
        XCTAssertFalse(version.migrationNeeded())
    }
    
    func testVersionMigrationIfVersionIsOlder() {
        let oldVersion = "0.9.1"
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        
        setVersionEnvironment(previousVersion: oldVersion, versionHistory: [oldVersion])
        
        let version = Version()
        let migrationNeeded = version.migrationNeeded()
        
        XCTAssertTrue(migrationNeeded)
        
        version.migrateVersion()
        
        XCTAssertEqual(version.previousVersion, currentVersion)
        XCTAssertTrue(version.versionHistory.contains(currentVersion))
    }
    
}
