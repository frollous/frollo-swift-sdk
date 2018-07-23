//
//  Preferences.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class Preferences {
    
    private let preferencesExtension = "plist"
    private let preferencesFileName = "FrolloSDKPreferences"
    private let preferencesPersistence: PreferencesPersistence
    
    init(path: URL) {
        let path = path.appendingPathComponent(preferencesFileName).appendingPathExtension(preferencesExtension)
        
        preferencesPersistence = PreferencesPersistence(path: path)
    }
    
    // MARK: - Management
    
    /**
     Reset all preferences to defaults and clear the persistent backing store
     */
    internal func reset() {
        preferencesPersistence.reset()
    }
    
    // MARK: - Preferences
    
    
    
}
