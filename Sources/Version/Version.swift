//
//  Version.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 9/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
    
    private let preferencesExtension = "plist"
    private let preferencesFileName = "FrolloSDKVersion"
    private let preferencesPersistence: PreferencesPersistence
    
    init(path: URL) {
        let path = path.appendingPathComponent(preferencesFileName).appendingPathExtension(preferencesExtension)
        
        preferencesPersistence = PreferencesPersistence(path: path)
        
        currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        previousVersion = preferencesPersistence[VersionConstants.appVersionLast] as? String
        if let appVersionHistory = preferencesPersistence[VersionConstants.appVersionHistory] as? [String] {
            versionHistory = appVersionHistory
        } else {
            versionHistory = [String]()
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
        // TODO: Keychain clear
        
        updatePreviousVersion()
    }
    
    /**
     Update the recorded previous version and version history of the app
     */
    private func updatePreviousVersion() {
        previousVersion = currentVersion
        versionHistory.append(currentVersion)
        
        preferencesPersistence[VersionConstants.appVersionLast] = currentVersion
        preferencesPersistence[VersionConstants.appVersionHistory] = versionHistory
        preferencesPersistence.synchronise()
    }
    
}
