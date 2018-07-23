//
//  PreferencesPersistence.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 23/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class PreferencesPersistence {
    
    private let preferencesPath: URL
    
    private var lock = NSLock()
    private var needsPersistence = false
    private var preferencesData = [String: Any]()
    
    init(path: URL) {
        preferencesPath = path
        
        loadPreferences()
    }
    
    internal subscript(key: String) -> Any? {
        get {
            defer { lock.unlock() }
            
            lock.lock()
            
            return preferencesData[key]
        }
        set {
            defer { lock.unlock() }
            
            lock.lock()
            
            if !needsPersistence {
                needsPersistence = true
                
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    self?.synchroniseIfNeeded()
                }
            }
            
            
            preferencesData[key] = newValue
        }
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
