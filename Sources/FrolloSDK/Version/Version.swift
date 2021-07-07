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

internal struct VersionConstants {
    static let appVersionHistory = "FrolloSDKVersion.appVersionHistory"
    static let appVersionLast = "FrolloSDKVersion.currentAppVersion"
    static let bundleShortVersion = "CFBundleShortVersionString"
    static let bundleVersion = "CFBundleVersion"
    static let suiteName = "us.frollo.FrolloSDKTests"
}

class Version {
    
    internal let currentVersion: String
    
    internal var previousVersion: String?
    internal var versionHistory: [String]
    
    private let keychain: Keychain
    private let preferencesExtension = "plist"
    private let preferencesFileName = "FrolloSDKVersion"
    private let preferencesPersistence: PreferencesPersistence
    
    init(path: URL, keychain: Keychain) {
        self.keychain = keychain
        
        let path = path.appendingPathComponent(preferencesFileName).appendingPathExtension(preferencesExtension)
        
        #if os(tvOS)
        preferencesPersistence = UserDefaultsPersistence()
        #else
        self.preferencesPersistence = PropertyListPersistence(path: path)
        #endif
        
        #if !SWIFT_PACKAGE
        self.currentVersion = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        #else
        self.currentVersion = "4.9.2"
        #endif
        self.previousVersion = preferencesPersistence[VersionConstants.appVersionLast] as? String
        if let appVersionHistory = preferencesPersistence[VersionConstants.appVersionHistory] as? [String] {
            self.versionHistory = appVersionHistory
        } else {
            self.versionHistory = [String]()
        }
    }
    
    /**
     Check if the version of the app has changed and a migration is needed
     
     - returns: Boolean indicating migration occurred or not
     */
    internal func migrationNeeded() -> Bool {
        if let lastVersion = previousVersion {
            if lastVersion.compare(currentVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending {
                return true
            }
        } else {
            // First install
            initialiseApp()
        }
        
        return false
    }
    
    /**
     Migrate the app to the latest version
     */
    internal func migrateVersion() {
        guard previousVersion != nil
        else {
            return
        }
        
        // Stubbed for future. Replace nil check with let and iterate through versions
        
        updatePreviousVersion()
    }
    
    // MARK: - Migration handling
    
    /**
     Initialises the app setting initial values and force clearing the keychain that can persist between installs
     */
    private func initialiseApp() {
        keychain.removeAll()
        
        updatePreviousVersion()
    }
    
    /**
     Update the recorded previous version and version history of the app
     */
    private func updatePreviousVersion() {
        previousVersion = currentVersion
        versionHistory.append(currentVersion)
        
        preferencesPersistence.setValue(currentVersion, for: VersionConstants.appVersionLast)
        preferencesPersistence.setValue(versionHistory, for: VersionConstants.appVersionHistory)
        preferencesPersistence.synchronise()
    }
    
}
