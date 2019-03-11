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
        
        #if os(tvOS)
        preferencesPersistence = UserDefaultsPersistence()
        #else
        self.preferencesPersistence = PropertyListPersistence(path: path)
        #endif
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
                    case "aggregation":
                        featureAggregation = featureFlag.enabled
                    default:
                        break
                }
            }
        }
    }
    
    // MARK: - Preferences
    
    @objc internal var loggedIn: Bool {
        get {
            return preferencesPersistence[#keyPath(loggedIn)] as? Bool ?? false
        }
        set {
            preferencesPersistence.setValue(newValue, for: #keyPath(loggedIn))
        }
    }
    
}
