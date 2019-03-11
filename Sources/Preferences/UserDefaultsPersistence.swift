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
