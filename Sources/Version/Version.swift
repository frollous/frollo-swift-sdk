//
//  Version.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 9/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class Version {
    
    internal struct VersionConstants {
        static let appVersionHistory = "FrolloSDKVersion.appVersionHistory"
        static let appVersionLast = "FrolloSDKVersion.currentAppVersion"
        static let bundleVersion = "CFBundleShortVersionString"
        static let suiteName = "us.frollo.FrolloSDKVersion"
    }
    
    internal let currentVersion: String
    
    internal var previousVersion: String?
    internal var versionHistory: [String]
    
    private let userDefaults = UserDefaults(suiteName: VersionConstants.suiteName)!
    
    init() {
        currentVersion = Bundle(for: Version.self).object(forInfoDictionaryKey: VersionConstants.bundleVersion) as! String
        previousVersion = userDefaults.string(forKey: VersionConstants.appVersionLast)
        if let appVersionHistory = userDefaults.object(forKey:VersionConstants.appVersionHistory) as? [String] {
            versionHistory = appVersionHistory
        } else {
            versionHistory = [String]()
        }
    }
    
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
    
    internal func migrateVersion() {
        guard previousVersion != nil
            else {
                return
        }
        
        // Stubbed for future. Replace nil check with let and iterate through versions
        
        updatePreviousVersion()
    }
    
    // MARK: - Migration handling
    
    private func initialiseApp() {
        // Force clean the keychain as this can persist from install to install
        // TODO: Keychain clear
        
        updatePreviousVersion()
    }
    
    private func updatePreviousVersion() {
        previousVersion = currentVersion
        versionHistory.append(currentVersion)
        
        UserDefaults.standard.set(currentVersion, forKey: VersionConstants.appVersionLast)
        UserDefaults.standard.set(versionHistory, forKey: VersionConstants.appVersionHistory)
        UserDefaults.standard.synchronize()
    }
    
}
