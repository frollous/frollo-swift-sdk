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

internal protocol UniqueManagedObject: AnyObject {
    
    static var entityName: String { get }
    static var primaryKey: String { get }
    
    var primaryID: Int64 { get }
    
    func linkObject(object: NSManagedObject)
    func update(response: APIUniqueResponse, context: NSManagedObjectContext)
    
}
