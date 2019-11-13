//
//  Copyright © 2018 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreData
import Foundation

class MessageMigration: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        struct MessageMigrationKeys {
            static let errorDomain = "MessageMigrationError"
            static let modelVersion = "ModelVersion"
        }
        
        if let modelVersion = mapping.userInfo?[MessageMigrationKeys.modelVersion] as? String {
            
            guard let destinationEntityName = mapping.destinationEntityName
            else {
                throw NSError(domain: MessageMigrationKeys.errorDomain, code: -1, userInfo: nil)
            }
            
            if modelVersion == "1.5.1" {
                let sourceKeys = Array(sInstance.entity.attributesByName.keys)
                let sourceValues = sInstance.dictionaryWithValues(forKeys: sourceKeys)
                
                let destinationInstance = NSEntityDescription.insertNewObject(forEntityName: destinationEntityName, into: manager.destinationContext)
                let destinationKeys = destinationInstance.entity.attributesByName.keys
                
                for key in destinationKeys {
                    switch key {
                        case "openModeRawValue":
                            guard let openExternalvalue = sourceValues["actionOpenExternal"] as? Bool
                            else {
                                throw NSError(domain: MessageMigrationKeys.errorDomain, code: -3, userInfo: nil)
                            }
                            
                            let newValue = openExternalvalue ? "external" : "internal"
                            destinationInstance.setValue(newValue, forKey: key)
                        default:
                            guard let value = sourceValues[key], (value is NSNull) == false
                            else {
                                continue
                            }
                            destinationInstance.setValue(value, forKey: key)
                    }
                }
                
                manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationInstance, for: mapping)
            }
        }
        
    }
}
