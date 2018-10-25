//
//  Database.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 29/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation

public class Database {
    
    struct DatabaseConstants {
        static let appDataFolder = "FrolloSDKData"
        static let modelExtension = "mom"
        static let modelName = "FrolloSDKDataModel"
        static let parentModelExtension = "momd"
        static let storeExtension = "sqlite"
        static let storeName = "FrolloSDKDatabase"
    }
    
    public var viewContext: NSManagedObjectContext {
        get {
            return persistentContainer.viewContext
        }
    }
    
    internal let storeURL: URL
    
    internal var persistentContainer: NSPersistentContainer
    
    static let model: NSManagedObjectModel = {
        let modelURL = Bundle(for: Database.self).url(forResource: DatabaseConstants.modelName, withExtension: DatabaseConstants.parentModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private var migrationLock = NSLock()
    
    // MARK: - Setup
    
    /**
     Sets up a Core Data stack with NSPersistentContainer to manager the NSManagedObjectContexts
     
     - parameters:
        - path: Path to folder where the database should be stored
     */
    init(path: URL) {
        storeURL = path.appendingPathComponent(DatabaseConstants.storeName).appendingPathExtension(DatabaseConstants.storeExtension)
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        persistentContainer = NSPersistentContainer(name: DatabaseConstants.storeName, managedObjectModel: Database.model)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
    }
    
    /**
     Setup the Core Data stack, loading data from the persistent store or creating if needed.
     If errors occur then the database should be reset on disk.
     
     - Warning: Must be called after any migration.
     
     - parameters:
        - completionHandler: Completion handler is called with error indicating if the setup was successful or not
    */
    internal func setup(completionHandler: @escaping (FrolloSDKError?) -> Void) {
        migrationLock.lock()
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let setupError = error {
                Log.error(setupError.localizedDescription)
                
                // Fallback to resetting the store
                self.destroyPersistentStore()
                
                self.persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, secondarySetupError) in
                    if let setupError = secondarySetupError {
                        Log.error(setupError.localizedDescription)
                        
                        let dataError = DataError(type: .database, subType: .corrupt)
                        completionHandler(dataError)
                    } else {
                        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                        
                        completionHandler(nil)
                    }
                })
            } else {
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Migration
    
    /**
     Indicates if there's an existing database store that needs migration before it can be used
     
     - returns: Boolean indicating if migration is needed
     */
    internal func needsMigration() -> Bool {
        guard FileManager.default.fileExists(atPath: storeURL.path)
            else {
                return false
        }
        
        do {
            let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL)
            
            let model = NSManagedObjectModel(contentsOf: Bundle(for: type(of: self)).url(forResource: DatabaseConstants.modelName, withExtension: DatabaseConstants.parentModelExtension)!)!
            return !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
        } catch let error {
            Log.error(error.localizedDescription)
            
            return false
        }
    }
    
    /**
     Perform a migration of the database before the database stack has been setup with a completion handler when the migration has succeeded or failed.
     In the event of failure the persistent store should be reset to bring the database back to a workable state.
     
     - parameters:
        - completionHandler: Completion handler is called with success boolean indicating success or failure
     
     - returns: Progress object indicating the migration progress so far
     */
    @discardableResult internal func migrate(completionHandler: @escaping (Bool) -> Void) -> Progress? {
        migrationLock.lock()

        let progress = Progress(totalUnitCount: 1)
        
        DispatchQueue.global(qos: .userInitiated).async {
            Log.info("Starting database migration...")
            
            // Gather all models
            let modelPath = Bundle(for: type(of: self)).url(forResource: Database.DatabaseConstants.modelName, withExtension: Database.DatabaseConstants.parentModelExtension)!
            var subPaths = Bundle(for: type(of: self)).urls(forResourcesWithExtension: Database.DatabaseConstants.modelExtension, subdirectory: modelPath.lastPathComponent)!
            
            subPaths.sort { (urlA: URL, urlB: URL) -> Bool in
                let urlAVersion = urlA.deletingPathExtension().lastPathComponent.components(separatedBy: "-").last!
                let urlBVersion = urlB.deletingPathExtension().lastPathComponent.components(separatedBy: "-").last!
                
                return urlAVersion.compare(urlBVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending
            }
            
            var previousPath: URL?
            
            for path in subPaths {
                do {
                    let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: self.storeURL)
                    
                    if let lastPath = previousPath {
                        let sourceModel = NSManagedObjectModel(contentsOf: lastPath)!
                        if sourceModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata) {
                            Log.info("Migrating model " + lastPath.path + " to " + path.path)
                            
                            let destinationModel = NSManagedObjectModel(contentsOf: path)!
                            if !self.performMigration(from: sourceModel, to: destinationModel) {
                                self.migrationLock.unlock()
                                completionHandler(false)
                                
                                break
                            }
                        }
                    }
                    
                    previousPath = path
                } catch let error {
                    Log.info("Database migration failed to find store metadata")
                    
                    Log.error(error.localizedDescription)
                    
                    self.migrationLock.unlock()
                    completionHandler(false)
                    
                    return
                }
            }
            
            // Check the final model matches
            do {
                let finalStoreMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: self.storeURL)
                
                let finalModel = NSManagedObjectModel(contentsOf: previousPath!)!
                if finalModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: finalStoreMetadata) {
                    self.migrationLock.unlock()
                    completionHandler(true)
                } else {
                    self.migrationLock.unlock()
                    completionHandler(false)
                }
            } catch let error {
                Log.info("Database migration failed to find final store metadata")
                
                Log.error(error.localizedDescription)
                
                self.migrationLock.unlock()
                completionHandler(false)
                
                return
            }
        }
        
        return progress
    }
    
    private func performMigration(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) -> Bool {
        var mappingModel = NSMappingModel(from: [Bundle(for: type(of: self))], forSourceModel: sourceModel, destinationModel: destinationModel)
        
        if mappingModel == nil {
            do {
                mappingModel = try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
            } catch let error {
                Log.error(error.localizedDescription)
                
                return false
            }
        }
        
        // Create a scratch directory to migrate to
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Log.error(error.localizedDescription)
            
            return false
        }
        
        defer {
            _ = try? FileManager.default.removeItem(at: tempDirectory)
        }
        
        // Migrate store to temporary location
        let destinationURL = tempDirectory.appendingPathComponent(storeURL.lastPathComponent)
        
        let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        do {
            try migrationManager.migrateStore(from: storeURL, sourceType: NSSQLiteStoreType, options: nil, with: mappingModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
        } catch let error as NSError {
            Log.error(error.localizedDescription)
            Log.debug(error.debugDescription)
            
            return false
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: destinationModel)
        do {
            try persistentStoreCoordinator.replacePersistentStore(at: storeURL, destinationOptions: nil, withPersistentStoreFrom: destinationURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        } catch let error {
            Log.error(error.localizedDescription)
            
            return false
        }
        
        return true
    }
    
    // MARK: - Reset
    
    /**
     Resets the persistent store and rebuilds the persistent container
    */
    internal func reset(completionHandler: @escaping (Error?) -> Void) {
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        persistentContainer = NSPersistentContainer(name: DatabaseConstants.storeName, managedObjectModel: Database.model)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        destroyPersistentStore()
        
        migrationLock.unlock()
        
        setup(completionHandler: completionHandler)
    }
    
    /**
     Deletes the persistent score on disk removing all data. Also resets corrupted databases
    */
    internal func destroyPersistentStore() {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: Database.model)
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    // MARK: - Managed Object Contexts
    
    /**
     Calls the persistent container to generate a new background managed object context
     
     - seealso: [NSPersistentContainer Documentation](https://developer.apple.com/documentation/coredata/nspersistentcontainer)
    */
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
}
