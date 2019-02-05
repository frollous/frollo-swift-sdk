//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

/// Frollo SDK Completion Handler with optional error if an issue occurs
public typealias FrolloSDKCompletionHandler = (Error?) -> Void

/// Frollo SDK manager and main instantiation. Responsible for managing the lifecycle and coordination of the SDK
public class FrolloSDK: AuthenticationDelegate, NetworkDelegate {
    
    /// Notification triggered when ever the authentication status of the SDK changes. Observe this notification to detect if the SDK user has authenticated or been logged out.
    public static let authenticationChangedNotification = Notification.Name(rawValue: "FrolloSDK.authenticationChangedNotification")
    
    /// User info key for authentication status sent with `authenticationChangedNotification` notifications.
    public static let authenticationStatusKey = "FrolloSDKKey.authenticationStatus"
    
    /// Global singleton for SDK
    public static let shared = FrolloSDK()
    
    /// Status of the FrolloSDK authentication with Frollo servers
    public enum FrolloSDKAuthenticationStatus {
        
        /// Authenticated
        case authenticated
        
        /// User was logged out
        case loggedOut
    }
    
    private struct FrolloSDKConstants {
        static let dataFolder = "FrolloSDKData"
        static let keychainService = "FrolloSDKKeychain"
    }
    
    static internal let dataFolderURL: URL = {
        #if os(tvOS)
        let folder = FileManager.SearchPathDirectory.cachesDirectory
        #else
        let folder = FileManager.SearchPathDirectory.applicationSupportDirectory
        #endif
        let urls = FileManager.default.urls(for: folder, in: .userDomainMask)
        var appDataURL = urls[0]
        appDataURL.appendPathComponent(FrolloSDKConstants.dataFolder)
        return appDataURL
    }()
    
    /// Delegate to get callbacks from certain events within the SDK such as messages being received
    public weak var delegate: FrolloSDKDelegate? {
        didSet {
            _events?.delegate = delegate
            _messages?.delegate = delegate
        }
    }
    
    /// Aggregation - All account and transaction related data see `Aggregation` for details
    public var aggregation: Aggregation {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _aggregation
        }
    }
    /// Authentication - All authentication and user related data see `Authentication` for details
    public var authentication: Authentication {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _authentication
        }
    }
    /// Bills - All bills and bill payments see `Bills` for details
    public var bills: Bills {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _bills
        }
    }
    /// Database - Core Data management and contexts for fetching data. See `Database` for details
    public var database: Database {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _database
        }
    }
    /// Events - Triggering and handling of events. See `Events` for details
    public var events: Events {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _events
        }
    }
    /// Messages - All messages management. See `Messages` for details
    public var messages: Messages {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _messages
        }
    }
    /// Notifications - Registering and handling of push notifications
    public var notifications: Notifications {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _notifications
        }
    }
    /// Reports - Aggregation data reports
    public var reports: Reports {
        get {
            guard _setup
                else {
                    fatalError("SDK not setup.")
            }
            
            return _reports
        }
    }
    
    /// Indicates if the SDK has completed setup or not
    public var setup: Bool {
        get {
            return _setup
        }
    }
    
    internal let _database: Database
    internal let keychain: Keychain
    internal let preferences: Preferences
    internal let version: Version
    
    internal var _aggregation: Aggregation!
    internal var _authentication: Authentication!
    internal var _bills: Bills!
    internal var _events: Events!
    internal var _messages: Messages!
    internal var _notifications: Notifications!
    internal var network: Network!
    internal var refreshTimer: Timer?
    internal var _reports: Reports!
    internal var _setup = false
    
    private let cacheExpiry: TimeInterval = 120
    private let frolloHost = "frollo.us"
    
    private var deviceLastUpdated: Date?
    
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
        self.version = Version(path: FrolloSDK.dataFolderURL, keychain: self.keychain)
    }
    
    /**
     Setup the SDK
     
     Sets up the SDK for use by performing any datbase migrations or other underlying setup needed. Must be called and completed before using the SDK.
     
     - parameters:
        - serverURL: Base URL of the Frollo API this SDK should point to
        - logLevel: Level of logging for debug and error messages
        - publicKeyPinningEnabled: Enable or disable public key pinning for *.frollo.us domains- useful for disabling in debug mode
        - completion: Completion handler with optional error if something goes wrong during the setup process
     
     - returns: Progress object indicating the migration progress so far if needed
    */
    @discardableResult public func setup(serverURL: URL, logLevel: LogLevel = .error, publicKeyPinningEnabled: Bool = true, completion: @escaping (Error?) -> Void) -> Progress? {
        guard !_setup
            else {
                fatalError("SDK already setup")
        }
        
        if version.migrationNeeded() {
            version.migrateVersion()
        }
        
        var pinnedKeys: [SecKey]?
        
        // Automatically pin Frollo server certificates
        if publicKeyPinningEnabled, let host = serverURL.host, host.contains(frolloHost) {
            let activeKey: SecKey
            let backupKey: SecKey
            
            let keyDict: [NSString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits: NSNumber(value: 256)
            ]
            
            var keyError: Unmanaged<CFError>?
            
            activeKey = SecKeyCreateWithData(PublicKey.active as CFData, keyDict as CFDictionary, &keyError)!
            backupKey = SecKeyCreateWithData(PublicKey.backup as CFData, keyDict as CFDictionary, &keyError)!
            
            if let error = keyError {
                Log.error(error.takeUnretainedValue().localizedDescription)
            } else {
                pinnedKeys = [activeKey, backupKey]
            }
        }
        
        network = Network(serverURL: serverURL, keychain: keychain, pinnedPublicKeys: pinnedKeys)
        network.delegate = self
        
        Log.manager.network = network
        Log.logLevel = logLevel
        
        _aggregation = Aggregation(database: _database, network: network)
        _authentication = Authentication(database: _database, network: network, preferences: preferences, delegate: self)
        _bills = Bills(database: _database, network: network, aggregation: _aggregation)
        _events = Events(network: network)
        _messages = Messages(database: _database, network: network)
        _notifications = Notifications(authentication: _authentication, events: _events, messages: _messages)
        _reports = Reports(database: _database, network: network, aggregation: _aggregation)
        
        _events.delegate = delegate
        _messages.delegate = delegate
        
        // Check for database migration and return progress object if relevant
        if _database.needsMigration() {
            return _database.migrate { (error) in
                if error != nil {
                    completion(error)
                } else {
                    self._database.setup() { (error) in
                        if error == nil {
                            self._setup = true
                        }
                        
                        completion(error)
                    }
                }
            }
        } else {
            _database.setup { (error) in
                if error == nil {
                    self._setup = true
                }
                
                completion(error)
            }
        }
        
        return nil
    }
    
    // MARK: - Reset
    
    /**
     Reset the SDK. Clears all caches, datbases and keychain entries. Called automatically from logout.
     
     - parameters:
        - completion: Completion handler with option error if something goes wrong (optional)
    */
    public func reset(completionHandler: ((Error?) -> Void)? = nil) {
        pauseScheduledRefreshing()
        
        authentication.reset()
        
        keychain.removeAll()
        
        database.reset { (error) in
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
        
        // Update device timezone, name and IDs regularly
        let now = Date()
        
        var updateDevice = true
        if let lastUpdated = deviceLastUpdated {
            let time = now.timeIntervalSince(lastUpdated)
            if time < cacheExpiry {
                updateDevice = false
            }
        }
        
        if updateDevice {
            deviceLastUpdated = now
            
            authentication.updateDevice()
        }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.refreshSecondary()
        }
        
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
        messages.refreshUnreadMessages()
    }
    
    /**
     Refresh data from other important APIs that frequently change but are less time sensitive, e.g. bill payments
    */
    private func refreshSecondary() {
        let fromDate = Date().startOfLastMonth()
        let toDate = Date().addingTimeInterval(31622400).endOfMonth()
        
        bills.refreshBillPayments(from: fromDate, to: toDate)
    }
    
    /**
     Refresh data from long lived sources which don't change often, e.g. transaction categories, providers
    */
    private func refreshSystem() {
        aggregation.refreshProviders()
        aggregation.refreshTransactionCategories()
        aggregation.refreshMerchants()
        bills.refreshBills()
        authentication.updateDevice()
    }
    
    // MARK: - Scheduled Refresh
    
    private func resumeScheduledRefreshing() {
        cancelRefreshTimer()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: cacheExpiry, repeats: true, block: { (timer: Timer) in
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
    
    // MARK: - Authentication Delegate
    
    func authenticationReset() {
        reset()
    }
    
    // MARK: - Network Delegate
    
    internal func forcedLogout() {
        guard authentication.loggedIn
            else {
                return
        }
        
        reset()
    }
    
}
