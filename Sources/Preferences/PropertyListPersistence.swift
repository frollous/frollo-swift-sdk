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

class PropertyListPersistence: PreferencesPersistence {
    
    private let preferencesPath: URL
    
    private var lock = NSLock()
    private var needsPersistence = false
    private var preferencesData = [String: Any]()
    
    init(path: URL) {
        self.preferencesPath = path
        
        loadPreferences()
    }
    
    internal subscript(key: String) -> Any? {
        get {
            defer { lock.unlock() }
            
            lock.lock()
            
            return preferencesData[key]
        }
        set {
            setValue(newValue, for: key)
        }
    }
    
    func setValue(_ value: Any?, for key: String) {
        defer { lock.unlock() }
        
        lock.lock()
        
        if !needsPersistence {
            needsPersistence = true
            
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?.synchroniseIfNeeded()
            }
        }
        
        preferencesData[key] = value
    }
    
    internal func reset() {
        resetPreferences()
    }
    
    internal func synchronise() {
        savePreferences()
    }
    
    // MARK: - Monitoring Persistence
    
    private func synchroniseIfNeeded() {
        if needsPersistence {
            savePreferences()
        }
    }
    
    // MARK: - Persistence
    
    private func loadPreferences() {
        defer { lock.unlock() }
        
        lock.lock()
        
        do {
            let data = try Data(contentsOf: preferencesPath)
            
            if let prefData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                preferencesData = prefData
            } else {
                preferencesData = [:]
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    private func savePreferences() {
        defer { lock.unlock() }
        
        lock.lock()
        
        needsPersistence = false
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: preferencesData, format: .xml, options: 0)
            
            do {
                try data.write(to: preferencesPath)
            } catch {
                Log.error(error.localizedDescription)
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    private func resetPreferences() {
        defer { lock.unlock() }
        
        lock.lock()
        
        preferencesData = [:]
        
        do {
            try FileManager.default.removeItem(at: preferencesPath)
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
}
