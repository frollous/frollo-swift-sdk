//
//  Copyright © 2019 Frollo. All rights reserved.
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

/**
 CDR Product Information
 
 Represents key information of CDR Product
 */
public class CDRConfiguration: NSManagedObject {
    
    public struct SharingDuration: Codable {
        public let duration: Int
        public let description: String
        public let imageURL: String
    }
    
    public var sharingDurations: [SharingDuration] {
        get {
            return try! JSONDecoder().decode([SharingDuration].self, from: sharingDurationRawValue)
        }
        set {
            sharingDurationRawValue = try! JSONEncoder().encode(newValue)
        }
    }
    
    internal func update(response: APICDRConfigurationResponse) {
        supportEmail = response.supportEmail
        adrID = response.adrID
        adrName = response.adrName
        sharingDurations = response.sharingDuration.map { SharingDuration(duration: $0.duration, description: $0.description, imageURL: $0.imageURL) }
    }
    
}
