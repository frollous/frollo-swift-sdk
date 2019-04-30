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
//

import CoreData
import Foundation

/**
 Tag
 
 Core Data representation of a user tag for transactions
 */
public class Tag: NSManagedObject {
    
    /// Core Data entity description name
    static var entityName = "Tag"
    
    internal static var primaryKey = #keyPath(Tag.name)
    
    // MARK: - Updating Object
    
    internal func linkObject(object: NSManagedObject) {
        // Not used
    }
    
    internal func update(response: APIUniqueResponse, context: NSManagedObjectContext) {
        if let tagResponse = response as? APITransactionTagResponse {
            update(response: tagResponse, context: context)
        }
    }
    
    internal func update(response: APITransactionTagResponse, context: NSManagedObjectContext) {
        name = response.name
        count = response.count ?? -1
        lastUsedAt = response.lastUsedAt
        createdAt = response.createdAt
    }
    
}

extension Tag {
    
    private static func all(predicate: NSPredicate?, context: NSManagedObjectContext) throws -> [Tag] {
        let fetchRequest = Tag.tagFetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: primaryKey, ascending: true)]
        return try context.fetch(fetchRequest)
    }
    
    static func all(including names: [String], context: NSManagedObjectContext) throws -> [Tag] {
        let predicate = NSPredicate(format: primaryKey + " IN %@", argumentArray: [names])
        return try Tag.all(predicate: predicate, context: context)
    }
    
    static func all(excluding names: [String], context: NSManagedObjectContext) throws -> [Tag] {
        let predicate = NSPredicate(format: "NOT " + primaryKey + " IN %@", argumentArray: [names])
        return try Tag.all(predicate: predicate, context: context)
    }
    
    static func all(context: NSManagedObjectContext) throws -> [Tag] {
        return try Tag.all(predicate: nil, context: context)
    }
}
