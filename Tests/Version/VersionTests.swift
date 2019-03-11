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

import XCTest
@testable import FrolloSDK

class VersionTests: XCTestCase {
    
    private let keychainService = "VersionTestsKeychain"
    private let tempFolderPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(UUID().uuidString, isDirectory: true)
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.createDirectory(at: tempFolderPath, withIntermediateDirectories: true, attributes: nil)
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        try? FileManager.default.removeItem(at: tempFolderPath)
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    // MARK: - Helpers
    
    private func setVersionEnvironment(path: URL, previousVersion: String, versionHistory: [String]) {
        let filePath = path.appendingPathComponent("FrolloSDKVersion").appendingPathExtension("plist")
        
        #if os(tvOS)
        let persistence = UserDefaultsPersistence()
        #else
        let persistence = PropertyListPersistence(path: filePath)
        #endif
        
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
    
    func testKeychainClearedFreshInstall() {
        let path = tempFolderPath
        
        let testKey = "TestKey"
        
        let keychain = Keychain(service: keychainService)
        keychain[testKey] = "RandomData"
        
        let version = Version(path: path, keychain: keychain)
        _ = version.migrationNeeded()
        
        XCTAssertNil(keychain[testKey])
    }
    
    func testVersionFreshInstall() {
        let path = tempFolderPath
        
        let version = Version(path: path, keychain: Keychain(service: keychainService))
        
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        XCTAssertEqual(currentVersion, version.currentVersion)
        XCTAssertNil(version.previousVersion)
        XCTAssertFalse(version.versionHistory.count > 0)
    }
    
    func testVersionFreshInstallMigrationDoesNothing() {
        let path = tempFolderPath
        
        let version = Version(path: path, keychain: Keychain(service: keychainService))
        version.migrateVersion()
        XCTAssertNil(version.previousVersion)
    }
    
    func testVersioMigrationNotNeededOnFreshInstall() {
        let path = tempFolderPath
        
        let version = Version(path: path, keychain: Keychain(service: keychainService))
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
        
        let version = Version(path: path, keychain: Keychain(service: keychainService))
        XCTAssertFalse(version.migrationNeeded())
    }
    
    func testVersionMigrationIfVersionIsOlder() {
        let oldVersion = "0.9.1"
        let currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        
        let path = tempPath()
        setVersionEnvironment(path: path, previousVersion: oldVersion, versionHistory: [oldVersion])
        
        sleep(1)
        
        let version = Version(path: path, keychain: Keychain(service: keychainService))
        let migrationNeeded = version.migrationNeeded()
        
        XCTAssertTrue(migrationNeeded)
        
        version.migrateVersion()
        
        XCTAssertEqual(version.previousVersion, currentVersion)
        XCTAssertTrue(version.versionHistory.contains(currentVersion))
    }
    
}
