//
//  CacheableManagedObject.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

protocol CacheableManagedObject: class {
    
    static var entityName: String { get }
    
    var primaryID: Int64 { get }
    var linkedID: Int64? { get }
    
    func linkObject(object: CacheableManagedObject)
    func update(response: APIUniqueResponse, context: NSManagedObjectContext)
    
}
