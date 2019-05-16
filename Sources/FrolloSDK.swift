//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

/// Frollo SDK Completion Handler with optional error if an issue occurs
public typealias FrolloSDKCompletionHandler = (EmptyResult<Error>) -> Void

/// Frollo SDK manager and main instantiation. Responsible for managing the lifecycle and coordination of the SDK
public class FrolloSDK: NetworkDelegate {
    
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
    
    internal static let dataFolderURL: URL = {
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
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _aggregation
    }
    
    /// Authentication - All authentication and user related data see `Authentication` for details
    public var authentication: Authentication {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _authentication
    }
    
    /// Default OAuth2 Authentication - Returns the default OAuth2 based authentication if no custom one has been applied
    public var defaultAuthentication: OAuth2Authentication? {
        return _authentication as? OAuth2Authentication
    }
    
    /// Bills - All bills and bill payments see `Bills` for details
    public var bills: Bills {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _bills
    }
    
    /// Database - Core Data management and contexts for fetching data. See `Database` for details
    public var database: Database {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _database
    }
    
    /// Events - Triggering and handling of events. See `Events` for details
    public var events: Events {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _events
    }
    
    /// Messages - All messages management. See `Messages` for details
    public var messages: Messages {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _messages
    }
    
    /// Notifications - Registering and handling of push notifications
    public var notifications: Notifications {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _notifications
    }
    
    /// Reports - Aggregation data reports
    public var reports: Reports {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _reports
    }
    
    /// Surveys - Surveys management. See `Surveys` for details
    public var surveys: Surveys {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _surveys
    }
    
    /// User - User Management. See `UserManagement` for details
    public var user: UserManagement {
        guard _setup
        else {
            fatalError("SDK not setup")
        }
        
        return _user
    }
    
    /// Indicates if the SDK has completed setup or not
    public var setup: Bool {
        return _setup
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
    internal var _surveys: Surveys!
    internal var _setup = false
    internal var _user: UserManagement!
    
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
        self.version = Version(path: FrolloSDK.dataFolderURL, keychain: keychain)
    }
    
    /**
     Setup the SDK
     
     Sets up the SDK for use by performing any datbase migrations or other underlying setup needed. Must be called and completed before using the SDK.
     
     - parameters:
        - configuration: Configuration and preferences needed to setup the SDK
        - completion: Completion handler with optional error if something goes wrong during the setup process
     
     - returns: Progress object indicating the migration progress so far if needed
     */
    @discardableResult public func setup(configuration: FrolloSDKConfiguration, completion: @escaping FrolloSDKCompletionHandler) -> Progress? {
        guard !_setup
        else {
            fatalError("SDK already setup")
        }
        
        if version.migrationNeeded() {
            version.migrateVersion()
        }
        
        var pinnedKeys: [URL: [SecKey]]?
        
        // Automatically pin Frollo server certificates
        var pinServer = false
        var pinToken = false
        
        if let host = configuration.serverEndpoint.host, host.contains(frolloHost) {
            pinServer = true
        }
        if let host = configuration.tokenEndpoint?.host, host.contains(frolloHost) {
            pinToken = true
        }
        
        if configuration.publicKeyPinningEnabled, pinServer || pinToken {
            let activeKey: SecKey
            let backupKey: SecKey
            
            let keyDict: [NSString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                            kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                            kSecAttrKeySizeInBits: NSNumber(value: 256)]
            
            var keyError: Unmanaged<CFError>?
            
            activeKey = SecKeyCreateWithData(PublicKey.active as CFData, keyDict as CFDictionary, &keyError)!
            backupKey = SecKeyCreateWithData(PublicKey.backup as CFData, keyDict as CFDictionary, &keyError)!
            
            if let error = keyError {
                Log.error(error.takeUnretainedValue().localizedDescription)
            } else {
                if pinServer {
                    pinnedKeys?[configuration.serverEndpoint] = [activeKey, backupKey]
                }
                if pinToken, let tokenURL = configuration.tokenEndpoint {
                    pinnedKeys?[tokenURL] = [activeKey, backupKey]
                }
            }
        }
        
        let networkAuthenticator = NetworkAuthenticator(serverEndpoint: configuration.serverEndpoint, keychain: keychain)
        network = Network(serverEndpoint: configuration.serverEndpoint, networkAuthenticator: networkAuthenticator, pinnedPublicKeys: pinnedKeys)
        network.delegate = self
        
        let service = APIService(serverEndpoint: configuration.serverEndpoint, network: network)
        
        Log.manager.service = service
        Log.logLevel = configuration.logLevel
        
        // Setup authentication stack
        switch configuration.authenticationType {
            case .custom:
                if let customAuthentication = configuration.authentication {
                    customAuthentication.delegate = network
                    
                    _authentication = customAuthentication
                } else {
                    fatalError("Custom authentication chosen but no class provided")
                }
                
            case .frollo:
                fallthrough
            case .oAuth2:
                guard let authorizationURL = configuration.authorizationEndpoint,
                    let tokenURL = configuration.tokenEndpoint,
                    let redirectURL = configuration.redirectURL,
                    let clientID = configuration.clientID
                else {
                    fatalError("Invalid OAuth2 configuration supplied")
                }
                
                let authService = OAuthService(authorizationEndpoint: authorizationURL, tokenEndpoint: tokenURL, redirectURL: redirectURL, network: network)
                _authentication = OAuth2Authentication(keychain: keychain, clientID: clientID, redirectURL: redirectURL, serverURL: configuration.serverEndpoint, authService: authService, preferences: preferences, delegate: network)
        }
        
        networkAuthenticator.authentication = _authentication
        
        _aggregation = Aggregation(database: _database, service: service, authentication: _authentication)
        _bills = Bills(database: _database, service: service, aggregation: _aggregation, authentication: _authentication)
        _events = Events(service: service, authentication: _authentication)
        _messages = Messages(database: _database, service: service, authentication: _authentication)
        _reports = Reports(database: _database, service: service, aggregation: _aggregation, authentication: _authentication)
        _surveys = Surveys(service: service, authentication: _authentication)
        _user = UserManagement(database: _database, service: service, authentication: _authentication, preferences: preferences)
        _notifications = Notifications(events: _events, messages: _messages, user: _user)
        
        _events.delegate = delegate
        _messages.delegate = delegate
        
        // Check for database migration and return progress object if relevant
        if _database.needsMigration() {
            return _database.migrate { error in
                if let migrationError = error {
                    self._database.destroyPersistentStore()
                    
                    completion(.failure(migrationError))
                } else {
                    self._database.setup { error in
                        if let setupError = error {
                            completion(.failure(setupError))
                        } else {
                            self._setup = true
                            
                            completion(.success)
                        }
                    }
                }
            }
        } else {
            _database.setup { error in
                if let setupError = error {
                    completion(.failure(setupError))
                } else {
                    self._setup = true
                    
                    completion(.success)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Reset and Logout
    
    /**
     Reset the SDK. Clears all caches, datbases and keychain entries. Called automatically from logout.
     
     - parameters:
        - completion: Completion handler with option error if something goes wrong (optional)
     */
    public func reset(completionHandler: FrolloSDKCompletionHandler? = nil) {
        pauseScheduledRefreshing()
        
        authentication.reset()
        
        network.reset()
        
        keychain.removeAll()
        
        database.reset { error in
            if let resetError = error {
                completionHandler?(.failure(resetError))
            } else {
                completionHandler?(.success)
            }
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
            
            user.updateDevice()
        }
    }
    
    /**
     Application received URL Open request
     
     Notify the SDK of an application open URL event. Used to handle OAuth2 and other login flows and deep links
     
     - returns: Indication if the URL was handled successfully or not
     
     */
    public func applicationOpen(url: URL) -> Bool {
        guard setup
        else {
            return false
        }
        
        return authentication.resumeAuthentication(url: url)
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
        user.refreshUser()
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
        bills.refreshBills()
        user.updateDevice()
    }
    
    // MARK: - Scheduled Refresh
    
    private func resumeScheduledRefreshing() {
        cancelRefreshTimer()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: cacheExpiry, repeats: true, block: { (_: Timer) in
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
        guard authentication.loggedIn
        else {
            return
        }
        
        reset()
    }
    
}
