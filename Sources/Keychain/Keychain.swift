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
import Security

class Keychain {
    
    internal enum Accessibility {
        /**
         Item data can only be accessed
         while the device is unlocked. This is recommended for items that only
         need be accesible while the application is in the foreground. Items
         with this attribute will migrate to a new device when using encrypted
         backups.
         */
        case whenUnlocked
        
        /**
         Item data can only be
         accessed once the device has been unlocked after a restart. This is
         recommended for items that need to be accesible by background
         applications. Items with this attribute will migrate to a new device
         when using encrypted backups.
         */
        case afterFirstUnlock
        
        /**
         Item data can always be accessed
         regardless of the lock state of the device. This is not recommended
         for anything except system use. Items with this attribute will migrate
         to a new device when using encrypted backups.
         */
        case always
        
        /**
         Item data can
         only be accessed while the device is unlocked. This class is only
         available if a passcode is set on the device. This is recommended for
         items that only need to be accessible while the application is in the
         foreground. Items with this attribute will never migrate to a new
         device, so after a backup is restored to a new device, these items
         will be missing. No items can be stored in this class on devices
         without a passcode. Disabling the device passcode will cause all
         items in this class to be deleted.
         */
        case whenPasscodeSetThisDeviceOnly
        
        /**
         Item data can only
         be accessed while the device is unlocked. This is recommended for items
         that only need be accesible while the application is in the foreground.
         Items with this attribute will never migrate to a new device, so after
         a backup is restored to a new device, these items will be missing.
         */
        case whenUnlockedThisDeviceOnly
        
        /**
         Item data can
         only be accessed once the device has been unlocked after a restart.
         This is recommended for items that need to be accessible by background
         applications. Items with this attribute will never migrate to a new
         device, so after a backup is restored to a new device these items will
         be missing.
         */
        case afterFirstUnlockThisDeviceOnly
        
        /**
         Item data can always
         be accessed regardless of the lock state of the device. This option
         is not recommended for anything except system use. Items with this
         attribute will never migrate to a new device, so after a backup is
         restored to a new device, these items will be missing.
         */
        case alwaysThisDeviceOnly
    }
    
    internal enum QueryType {
        case create
        case read
        case remove
    }
    
    let accessibility: Accessibility
    let accessGroup: String?
    let service: String
    
    private let baseQuery: [String: Any]
    
    init(service: String, accessibility: Accessibility = .afterFirstUnlockThisDeviceOnly, accessGroup: String? = nil) {
        self.accessibility = accessibility
        self.accessGroup = accessGroup
        self.service = service
        
        self.baseQuery = [kSecClass as String: kSecClassGenericPassword,
                          kSecAttrService as String: service]
    }
    
    // MARK: - Keychain Values
    
    internal func get(key: String) -> String? {
        var readQuery = query(type: .read, key: key)
        readQuery[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(readQuery as CFDictionary, &result)
        switch status {
            case errSecSuccess:
                if let value = result as? Data, let string = String(data: value, encoding: .utf8) {
                    return string
                }
            default:
                break
        }
        
        return nil
    }
    
    internal func set(key: String, value: String) {
        guard let data = value.data(using: .utf8)
        else {
            return
        }
        
        // Update item if it already exists
        let readQuery = query(type: .read, key: key)
        
        var status = SecItemUpdate(readQuery as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        
        switch status {
            case errSecItemNotFound:
                // Item not found, create it
                let updateQuery = query(type: .create, key: key, value: data)
                status = SecItemAdd(updateQuery as CFDictionary, nil)
            default:
                break
        }
    }
    
    internal func remove(key: String) {
        let removeQuery = query(type: .remove, key: key)
        
        SecItemDelete(removeQuery as CFDictionary)
    }
    
    internal func removeAll() {
        let removeAllQuery = query(type: .remove)
        
        SecItemDelete(removeAllQuery as CFDictionary)
    }
    
    // MARK: - Keychain Subscript
    
    internal subscript(key: String) -> String? {
        get {
            return get(key: key)
        }
        
        set {
            if let value = newValue {
                set(key: key, value: value)
            } else {
                remove(key: key)
            }
        }
    }
    
    // MARK: - Keychain Helpers
    
    private func query(type: QueryType, key: String? = nil, value: Data? = nil) -> [String: Any] {
        var query = baseQuery
        
        if let queryAccessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = queryAccessGroup
        }
        
        if let queryKey = key {
            query[kSecAttrAccount as String] = queryKey
        }
        
        if let queryData = value {
            query[kSecValueData as String] = queryData
        }
        
        #if os(macOS)
        switch type {
        case .create:
            break
        case .read:
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnData as String] = kCFBooleanTrue
        case .remove:
            query[kSecMatchLimit as String] = kSecMatchLimitAll
        }
        #endif
        
        switch accessibility {
            case .whenUnlocked:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
            case .afterFirstUnlock:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            case .always:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleAlways
            case .whenPasscodeSetThisDeviceOnly:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlockedThisDeviceOnly:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            case .afterFirstUnlockThisDeviceOnly:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .alwaysThisDeviceOnly:
                query[kSecAttrAccessible as String] = kSecAttrAccessibleAlwaysThisDeviceOnly
        }
        
        return query
    }
    
}
