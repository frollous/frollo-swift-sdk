//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

public typealias FrolloSDKCompletionHandler = (Error?) -> Void

/// Frollo SDK manager and main instantiation. Responsible for managing the lifecycle and coordination of the SDK
public class FrolloSDK: NetworkDelegate {
    
    /// Notification triggered when ever the authentication status of the SDK changes. Observe this notification to detect if the SDK user has authenticated or been logged out.
    public static let authenticationChangedNotification = Notification.Name(rawValue: "FrolloSDK.authenticationChangedNotification")
    
    /// User info key for authentication status sent with `authenticationChangedNotification` notifications.
    public static let authenticationStatusKey = "FrolloSDKKey.authenticationStatus"
    
    public static let shared = FrolloSDK()
    
    /// Status of the FrolloSDK authentication with Frollo servers
    public enum FrolloSDKAuthenticationStatus {
        case authenticated
        case loggedOut
    }
    
    private struct FrolloSDKConstants {
        static let dataFolder = "FrolloSDKData"
        static let keychainService = "FrolloSDKKeychain"
    }
    
    static internal let dataFolderURL: URL = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        var appDataURL = urls[0]
        appDataURL.appendPathComponent(FrolloSDKConstants.dataFolder)
        return appDataURL
    }()
    
    public var aggregation: Aggregation {
        get {
            guard setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _aggregation
        }
    }
    public var authentication: Authentication {
        get {
            guard setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _authentication
        }
    }
    public var database: Database {
        get {
            guard setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _database
        }
    }
    
    internal let _database: Database
    internal let keychain: Keychain
    internal let preferences: Preferences
    
    internal var _aggregation: Aggregation!
    internal var _authentication: Authentication!
    internal var network: Network!
    internal var refreshTimer: Timer?
    internal var setup = false
    
    // MARK: - Setup
    
    /**
     Initialises the SDK
     
     Initialises an SDK instance. Only one instance should be instantiated. Setup must be run before use
    */
    internal init() {
        // Create data folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: FrolloSDK.dataFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: FrolloSDK.dataFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("FrolloSDK could not create app data folder. SDK cannot function without this.")
            }
        }
        
        self._database = Database(path: FrolloSDK.dataFolderURL)
        self.keychain = Keychain(service: FrolloSDKConstants.keychainService)
        self.preferences = Preferences(path: FrolloSDK.dataFolderURL)
    }
    
    /**
     Setup the SDK
     
     Sets up the SDK for use by performing any datbase migrations or other underlying setup needed. Must be called and completed before using the SDK.
     
     - parameters:
        - serverURL: Base URL of the Frollo API this SDK should point to
        - logLevel: Level of logging for debug and error messages
        - completion: Completion handler with optional error if something goes wrong during the setup process
    */
    public func setup(serverURL: URL, logLevel: LogLevel = .error, completion: @escaping (Error?) -> Void) {
        network = Network(serverURL: serverURL, keychain: keychain)
        network.delegate = self
        
        Log.manager.network = network
        Log.logLevel = logLevel
        
        _aggregation = Aggregation(database: _database, network: network)
        _authentication = Authentication(database: _database, network: network, preferences: preferences)
        
        _database.setup { (error) in
            if error == nil {
                self.setup = true
            }
            
            completion(error)
        }
    }
    
    // MARK: - Logout and Reset
    
    /**
     Logout the currently authenticated user from Frollo backend. Resets all caches and databases.
     
     - parameters:
        - completion: Completion handler with optional error if something goes wrong during the logout process (optional)
    */
    public func logout(completion: ((Error?) -> Void)? = nil) {
        authentication.logoutUser()
        
        reset(completionHandler: completion)
    }
    
    /**
     Reset the SDK. Clears all caches, datbases and keychain entries. Called automatically from logout.
     
     - parameters:
        - completion: Completion handler with option error if something goes wrong (optional)
    */
    public func reset(completionHandler: ((Error?) -> Void)? = nil) {
        pauseScheduledRefreshing()
        
        authentication.reset()
        
        keychain.removeAll()
        
        _aggregation = nil
        _authentication = nil
        
        database.reset { (error) in
            self.setup = false
            
            completionHandler?(error)
        }
        
        NotificationCenter.default.post(name: FrolloSDK.authenticationChangedNotification, object: self, userInfo: [FrolloSDK.authenticationStatusKey: FrolloSDKAuthenticationStatus.loggedOut])
    }
    
    // MARK: - Lifecycle
    
    /**
     Application entered the background or is about to terminate.
     
     Notify the SDK of an app lifecycle change. Call this to ensure proper refreshing of cache data occurs when the app enters background or resumes.
    */
    public func applicationDidEnterBackground() {
        pauseScheduledRefreshing()
    }
    
    /**
     Application resumed from background
     
     Notify the SDK of an app lifecycle change. Call this to ensure proper refreshing of cache data occurs when the app enters background or resumes.
     */
    public func applicationWillEnterForeground() {
        resumeScheduledRefreshing()
    }
    
    // MARK: - Refresh
    
    /**
     Refreshes all cached data in an optimised way. Fetches most urgent data first and then proceeds to update other caches if needed.
    */
    public func refreshData() {
        guard !database.needsMigration()
            else {
                return
        }
        
        refreshPrimary()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.refreshSecondary()
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.refreshSystem()
        }
        
        resumeScheduledRefreshing()
    }
    
    /**
     Refresh data from the most time sensitive and important APIs, e.g. accounts, transactions
    */
    private func refreshPrimary() {
        aggregation.refreshProviderAccounts()
        aggregation.refreshAccounts()
        aggregation.refreshTransactions(from: Date().startOfLastMonth(), to: Date().endOfMonth())
        authentication.refreshUser()
    }
    
    /**
     Refresh data from long lived sources which don't change often, e.g. transaction categories, providers
    */
    private func refreshSystem() {
        aggregation.refreshProviders()
        aggregation.refreshTransactionCategories()
        aggregation.refreshMerchants()
    }
    
    // MARK: - Scheduled Refresh
    
    private func resumeScheduledRefreshing() {
        cancelRefreshTimer()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true, block: { (timer: Timer) in
            self.refreshPrimary()
        })
    }
    
    private func pauseScheduledRefreshing() {
        cancelRefreshTimer()
    }
    
    private func cancelRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Network Delegate
    
    internal func forcedLogout() {
        reset()
    }
    
}
