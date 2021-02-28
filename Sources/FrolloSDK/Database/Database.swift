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

/// Managed the Core Data backed local cache of data
public class Database {
    
    struct DatabaseConstants {
        static let appDataFolder = "FrolloSDKData"
        static let modelExtension = "mom"
        static let modelName = "FrolloSDKDataModel"
        static let parentModelExtension = "momd"
        static let storeExtension = "sqlite"
        static let storeName = "FrolloSDKDatabase"
    }
    
    /// Main thread context for use by views see `NSPersistentContainer` for details
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    internal let storeURL: URL
    internal let targetName: String?
    
    internal var persistentContainer: NSPersistentContainer
    
    static let model: NSManagedObjectModel = {
        let modelURL = Bundle.module.url(forResource: DatabaseConstants.modelName, withExtension: DatabaseConstants.parentModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private let persistentHistoryExtension = "plist"
    private let persistentHistoryFileName = "FrolloSDKPersistentHistory"
    private let persistentHistoryKey = "PersistentHistoryKey"
    private let persistentHistoryPersistence: PreferencesPersistence
    
    private var migrationLock = NSLock()
    
    // MARK: - Setup
    
    /**
     Sets up a Core Data stack with NSPersistentContainer to manager the NSManagedObjectContexts
     
     - parameters:
        - path: Path to folder where the database should be stored
        - targetName: Name of the target consuming the SDK (Optional)
     */
    internal init(path: URL, targetName: String? = nil) {
        self.storeURL = path.appendingPathComponent(DatabaseConstants.storeName).appendingPathExtension(DatabaseConstants.storeExtension)
        self.targetName = targetName
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        let persistentHistoryPath = path.appendingPathComponent(persistentHistoryFileName).appendingPathExtension(persistentHistoryExtension)
        
        #if os(tvOS)
        persistentHistoryPersistence = UserDefaultsPersistence()
        #else
        self.persistentHistoryPersistence = PropertyListPersistence(path: persistentHistoryPath)
        #endif
        
        // If a user specified a target name setup persistent history tracking
        if targetName != nil {
            if #available(iOS 11.0, iOSApplicationExtension 11.0, tvOS 11.0, macOS 10.13, *) {
                storeDescription.setOption(NSNumber(booleanLiteral: true), forKey: NSPersistentHistoryTrackingKey)
            } else {
                Log.debug("Persistent History Tracking is only supported on iOS 11 or later.")
            }
        }
        
        self.persistentContainer = NSPersistentContainer(name: DatabaseConstants.storeName, managedObjectModel: Database.model)
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
        
        persistentContainer.loadPersistentStores { _, error in
            if let setupError = error {
                Log.error(setupError.localizedDescription)
                
                // Fallback to resetting the store
                self.destroyPersistentStore()
                
                self.persistentContainer.loadPersistentStores(completionHandler: { _, secondarySetupError in
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
                
                DispatchQueue.main.async {
                    self.mergeHistory()
                }
                
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
            
            let model = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: DatabaseConstants.modelName, withExtension: DatabaseConstants.parentModelExtension)!)!
            return !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
        } catch {
            Log.error(error.localizedDescription)
            
            return false
        }
    }
    
    /**
     Perform a migration of the database before the database stack has been setup with a completion handler when the migration has succeeded or failed.
     In the event of failure the persistent store should be reset to bring the database back to a workable state.
     
     - parameters:
        - completionHandler: Completion handler is called with optional error if there's an issue
     
     - returns: Progress object indicating the migration progress so far
     */
    @discardableResult internal func migrate(completionHandler: @escaping (Error?) -> Void) -> Progress? {
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
            
            var count = 0
            var totalFound = false
            
            for path in subPaths {
                do {
                    let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: self.storeURL)
                    
                    if let lastPath = previousPath {
                        let sourceModel = NSManagedObjectModel(contentsOf: lastPath)!
                        if sourceModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata) {
                            Log.info("Migrating model " + lastPath.path + " to " + path.path)
                            
                            if !totalFound {
                                totalFound = true
                                
                                progress.totalUnitCount = Int64(subPaths.count - count)
                            }
                            
                            let destinationModel = NSManagedObjectModel(contentsOf: path)!
                            
                            do {
                                try self.performMigration(from: sourceModel, to: destinationModel)
                            } catch let error as NSError {
                                self.migrationLock.unlock()
                                
                                Log.error(error.localizedDescription)
                                Log.debug(error.debugDescription)
                                
                                completionHandler(error)
                                return
                            }
                            
                            progress.completedUnitCount += 1
                        }
                    }
                    
                    previousPath = path
                } catch let error as NSError {
                    Log.error("Database migration failed to find store metadata")
                    
                    Log.error(error.localizedDescription)
                    Log.debug(error.debugDescription)
                    
                    self.migrationLock.unlock()
                    completionHandler(error)
                    
                    return
                }
                
                count += 1
            }
            
            // Check the final model matches
            do {
                let finalStoreMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: self.storeURL)
                
                let finalModel = NSManagedObjectModel(contentsOf: previousPath!)!
                if finalModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: finalStoreMetadata) {
                    self.migrationLock.unlock()
                    completionHandler(nil)
                } else {
                    self.migrationLock.unlock()
                    
                    let error = DataError(type: .database, subType: .migrationFailed)
                    
                    completionHandler(error)
                }
            } catch let error as NSError {
                Log.info("Database migration failed to find final store metadata")
                
                Log.error(error.localizedDescription)
                Log.debug(error.debugDescription)
                
                self.migrationLock.unlock()
                completionHandler(error)
                
                return
            }
        }
        
        return progress
    }
    
    private func performMigration(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) throws {
        var mappingModel = NSMappingModel(from: [Bundle(for: type(of: self))], forSourceModel: sourceModel, destinationModel: destinationModel)
        
        if mappingModel == nil {
            do {
                mappingModel = try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
            } catch let error as NSError {
                Log.error(error.localizedDescription)
                Log.debug(error.debugDescription)
                
                throw error
            }
        }
        
        // Create a scratch directory to migrate to
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            Log.error(error.localizedDescription)
            Log.debug(error.debugDescription)
            
            throw error
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
            
            throw error
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: destinationModel)
        do {
            try persistentStoreCoordinator.replacePersistentStore(at: storeURL, destinationOptions: nil, withPersistentStoreFrom: destinationURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        } catch let error as NSError {
            Log.error(error.localizedDescription)
            Log.debug(error.debugDescription)
            
            throw error
        }
    }
    
    // MARK: - Reset
    
    /**
     Resets the persistent store and rebuilds the persistent container
     */
    internal func reset(completionHandler: @escaping (Error?) -> Void) {
        Log.debug("SDK Database reset initiated...")
        
        persistentHistoryPersistence.reset()
        
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
        
        // Fallback cleanup
        let databaseSHMFileURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        let databaseWALFileURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let databaseFiles = [storeURL, databaseSHMFileURL, databaseWALFileURL]
        for file in databaseFiles {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    // MARK: - Merging Persistent History Changes
    
    /**
     Merge persistent history changes
     
     Merges persistent history changes from any other targets then clears the history of all up to date targets.
     Call this whenever initialising or resuming an app, extension or companion (e.g. watch) app
     */
    internal func mergeHistory() {
        guard #available(iOS 11.0, iOSApplicationExtension 11.0, tvOS 11.0, macOS 10.13, *)
        else {
            return
        }
        
        let timestamp: Date
        
        if let lastTimestamp = lastCommonPersistentHistoryTimestamp() {
            timestamp = lastTimestamp
        } else {
            timestamp = Date.distantPast
        }
        
        do {
            try mergeHistory(since: timestamp)
            try deleteHistory(since: timestamp)
        } catch {
            Log.error("Failed to merge persistent history changes: " + error.localizedDescription)
        }
    }
    
    /**
     Merge all persistent history changes since a particular date to the main context
     
     - parameters:
        - timestamp: The timestamp to merge changes since
     
     Since: iOS 11
     */
    @available(iOS 11.0, iOSApplicationExtension 11.0, tvOS 11.0, macOS 10.13, *)
    private func mergeHistory(since timestamp: Date) throws {
        let historyChangeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: timestamp)
        
        guard let historyResult = try viewContext.execute(historyChangeRequest) as? NSPersistentHistoryResult,
            let history = historyResult.result as? [NSPersistentHistoryTransaction]
        else {
            Log.error("Failure to convert persistent history result to history transactions")
            return
        }
        
        for transaction in history {
            viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
        }
        
        if let lastTimestamp = history.last?.timestamp {
            updatePersistentHistoryTimestamp(lastTimestamp)
        }
    }
    
    /**
     Delete all persistent history changes that have been merged into all targets
     */
    @available(iOS 11.0, iOSApplicationExtension 11.0, tvOS 11.0, macOS 10.13, *)
    private func deleteHistory(since timestamp: Date) throws {
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        try viewContext.execute(deleteHistoryRequest)
    }
    
    /**
     Returns the latest persistent history transaction timestamp that is common to all targets given.
     */
    private func lastCommonPersistentHistoryTimestamp() -> Date? {
        guard let targets = persistentHistoryPersistence[persistentHistoryKey] as? [String: Date]
        else {
            return nil
        }
        
        return targets.values.min()
    }
    
    private func updatePersistentHistoryTimestamp(_ timestamp: Date) {
        guard let target = targetName
        else {
            return
        }
        
        var targets: [String: Date]
        if let existingTargets = persistentHistoryPersistence[persistentHistoryKey] as? [String: Date] {
            targets = existingTargets
        } else {
            targets = [String: Date]()
        }
        
        targets[target] = timestamp
        
        persistentHistoryPersistence.setValue(targets, for: persistentHistoryKey)
        persistentHistoryPersistence.synchronise()
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
