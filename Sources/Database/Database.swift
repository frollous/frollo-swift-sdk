//
//  Database.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 29/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

class Database {
    
    struct DatabaseConstants {
        static let appDataFolder = "FrolloSDKData"
        static let modelExtension = "mom"
        static let modelName = "FrolloSDKDataModel"
        static let parentModelExtension = "momd"
        static let storeExtension = "sqlite"
        static let storeName = "FrolloSDKDatabase"
    }
    
    private var migrationLock = NSLock()
    
    static internal let storeURL: URL = {
        var storeURL = FrolloSDK.dataFolderURL.appendingPathComponent(DatabaseConstants.storeName)
        storeURL.appendPathExtension(DatabaseConstants.storeExtension)
        return storeURL
    }()
    
    internal var persistentContainer: NSPersistentContainer
    internal var viewContext: NSManagedObjectContext {
        get {
            return persistentContainer.viewContext
        }
    }
    
    private let model: NSManagedObjectModel
    
    // MARK: - Setup
    
    /**
     Sets up a Core Data stack with NSPersistentContainer to manager the NSManagedObjectContexts
     */
    init() {
        let modelURL = Bundle(for: type(of: self)).url(forResource: DatabaseConstants.modelName, withExtension: DatabaseConstants.parentModelExtension)!
        model = NSManagedObjectModel(contentsOf: modelURL)!
        
        let storeDescription = NSPersistentStoreDescription(url: Database.storeURL)
        persistentContainer = NSPersistentContainer(name: DatabaseConstants.storeName, managedObjectModel: model)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
    }
    
    /**
     Setup the Core Data stack, loading data from the persistent store or creating if needed.
     If errors occur then the database should be reset on disk.
     
     - Warning: Must be called after any migration.
     
     - parameters:
        - completionHandler: Completion handler is called with error indicating if the setup was successful or not
    */
    internal func setup(completionHandler: @escaping (Error?) -> Void) {
        migrationLock.lock()
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let setupError = error {
                // TODO: Replace with logging
                print(setupError.localizedDescription)
                
                // Fallback to resetting the store
                self.destroyPersistentStore()
                
                self.persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, secondarySetupError) in
                    if let setupError = secondarySetupError {
                        // TODO: Replace with logging
                        print(setupError.localizedDescription)
                    }
                    
                    completionHandler(secondarySetupError)
                })
            } else {
                completionHandler(error)
            }
        }
    }
    
    // MARK: - Migration
    
    /**
     Indicates if there's an existing database store that needs migration before it can be used
     
     - returns: Boolean indicating if migration is needed
     */
    internal func needsMigration() -> Bool {
        guard FileManager.default.fileExists(atPath: Database.storeURL.path)
            else {
                return false
        }
        
        do {
            let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: Database.storeURL)
            
            let model = NSManagedObjectModel(contentsOf: Bundle(for: type(of: self)).url(forResource: DatabaseConstants.modelName, withExtension: DatabaseConstants.parentModelExtension)!)!
            return !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
        } catch let error {
            // TODO: Replace with logging
            print(error.localizedDescription)
            
            return false
        }
    }
    
    /**
     Perform a migration of the database before the database stack has been setup with a completion handler when the migration has succeeded or failed.
     In the event of failure the persistent store should be reset to bring the database back to a workable state.
     
     - parameters:
        - completionHandler: Completion handler is called with success indicating success or failure
     
     */
//    internal func migrate(completionHandler: @escaping (Bool) -> Void) -> Progress? {
//        migrationLock.lock()
//
//        let progress = Progress(totalUnitCount: 1)
//
//        let modelURL = Bundle(for: type(of: self)).url(forResource: DatabaseConstants.storeName, withExtension: DatabaseConstants.parentModelExtension)!
//        let model = NSManagedObjectModel(contentsOf: modelURL)!
//
//        let storeDescription = NSPersistentStoreDescription(url: Database.storeURL)
//        storeDescription.shouldMigrateStoreAutomatically = true
//        storeDescription.shouldInferMappingModelAutomatically = true
//
//        let migrationContainer = NSPersistentContainer(name: DatabaseConstants.modelName, managedObjectModel: model)
//        migrationContainer.persistentStoreDescriptions = [storeDescription]
//
//        migrationContainer.loadPersistentStores { (persistentStoreDescription, error) in
//            self.migrationLock.unlock()
//
//            if let migrationError = error {
//                // TODO: Replace with logging
//                print("Database store migration failed.")
//                print(migrationError.localizedDescription)
//
//                completionHandler(false)
//            } else {
//                // TODO: Replace with logging
//                print("Database store successfully migrated.")
//
//                completionHandler(true)
//            }
//        }
//
//        return progress
//    }
    
    // MARK: - Reset
    
    internal func reset(completionHandler: @escaping (Error?) -> Void) {
        let storeDescription = NSPersistentStoreDescription(url: Database.storeURL)
        persistentContainer = NSPersistentContainer(name: DatabaseConstants.storeName, managedObjectModel: model)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        destroyPersistentStore()
        
        migrationLock.unlock()
        
        setup(completionHandler: completionHandler)
    }
    
    internal func destroyPersistentStore() {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at: Database.storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch {
            // TODO: Replace with logging
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Managed Object Contexts
    
    internal func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
}
