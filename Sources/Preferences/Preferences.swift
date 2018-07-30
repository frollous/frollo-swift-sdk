//
//  Preferences.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

class Preferences {
    
    enum FeatureKey: String {
        case aggregation
    }
    
    internal var featureAggregation = true
    
    private let featureLock = NSLock()
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
    
    // MARK: - Feature Flags
    
    internal func refreshFeatures(user: User) {
        featureLock.lock(); defer { featureLock.unlock() }
        
        if let featureFlags = user.features {
            for featureFlag in featureFlags {
                switch featureFlag.feature {
                    case .aggregation:
                        featureAggregation = featureFlag.enabled
                }
            }
        }
    }
    
    // MARK: - Preferences
    
    
    
}
