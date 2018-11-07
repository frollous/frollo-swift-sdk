//
//  UserDefaultsPersistence.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 7/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

#if os(tvOS) || os(iOS)
import UIKit
#endif

class UserDefaultsPersistence: PreferencesPersistence {
    
    private let namespacePrefix = "FrolloSDK."
    
    internal subscript(key: String) -> Any? {
        get {
            return UserDefaults.standard.value(forKey: namespacePrefix + key)
        }
        set {
            setValue(newValue, for: key)
        }
    }
    
    func setValue(_ value: Any?, for key: String) {
        UserDefaults.standard.set(value, forKey: namespacePrefix + key)
    }
    
    internal func reset() {
        let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
        
        for userDefault in defaultsDictionary {
            if userDefault.key.hasPrefix(namespacePrefix) {
                UserDefaults.standard.removeObject(forKey: userDefault.key)
            }
        }
    }
    
    internal func synchronise() {
        UserDefaults.standard.synchronize()
    }
    
}
