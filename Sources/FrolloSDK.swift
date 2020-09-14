//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

/// Frollo SDK Completion Handler with optional error if an issue occurs
public typealias FrolloSDKCompletionHandler = (EmptyResult<Error>) -> Void

/// Frollo SDK Completion Handler with pagination optional before and after cursors and optional error if an issue occurs
public typealias FrolloSDKPaginatedCompletionHandler = (Result<PaginationInfo, Error>) -> Void

/// Result with information of Pagination cursors and total count
public typealias PaginationInfo = (before: String?, after: String?, total: Int?)

/// Frollo SDK manager and main instantiation. Responsible for managing the lifecycle and coordination of the SDK
public class Frollo: OAuth2AuthenticationDelegate, UserManagementDelegate {
    
    /// Global singleton for SDK
    public static let shared = Frollo()
    
    private struct FrolloSDKConstants {
        static let dataFolder = "FrolloSDKData"
        static let keychainService = "FrolloSDKKeychain"
    }
    
    /// Default directory used to store data if not overriden
    public static let defaultDataFolderURL: URL = {
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
    public var oAuth2Authentication: OAuth2Authentication?
    
    /// Bills - All bills and bill payments see `Bills` for details
    public var bills: Bills {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _bills
    }
    
    /// Budgets - Tracking and managing budgets. See `Budget` for details
    public var budgets: Budgets {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _budgets
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
    
    /// Goals - Tracking and managing goals. See `Goals` for details
    public var goals: Goals {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _goals
    }
    
    /// Images - All images management. See `Images` for details
    public var images: Images {
        guard _setup
        else {
            fatalError("SDK not setup.")
        }
        
        return _images
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
    
    /// PayDays - Managing and detecting the user's pay cycle
    public var payDays: PayDays {
        guard _setup
        else {
            fatalError("SDK not setup")
        }
        
        return _payDays
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
    public var userManagement: UserManagement {
        guard _setup
        else {
            fatalError("SDK not setup")
        }
        
        return _userManagement
    }
    
    /// Indicates if the SDK has completed setup or not
    public var setup: Bool {
        return _setup
    }
    
    internal let keychain: Keychain
    
    internal var _aggregation: Aggregation!
    internal var _authentication: Authentication!
    internal var _bills: Bills!
    internal var _budgets: Budgets!
    internal var _database: Database!
    internal var _events: Events!
    internal var _goals: Goals!
    internal var _images: Images!
    internal var _messages: Messages!
    internal var _notifications: Notifications!
    internal var network: Network!
    internal var service: APIService!
    internal var _payDays: PayDays!
    internal var preferences: Preferences!
    internal var refreshTimer: Timer?
    internal var _reports: Reports!
    internal var _surveys: Surveys!
    internal var _setup = false
    internal var _userManagement: UserManagement!
    internal var version: Version!
    
    private let cacheExpiry: TimeInterval = 120
    private let frolloHost = "frollo.us"
    
    private var deviceLastUpdated: Date?
    private var notificationToken: Data?
    
    // MARK: - Setup
    
    /**
     Initialises the SDK
     
     Initialises an SDK instance. Only one instance should be instantiated. Setup must be run before use
     */
    internal init() {
        self.keychain = Keychain(service: FrolloSDKConstants.keychainService)
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
        
        // Create data folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: configuration.dataDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: configuration.dataDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("FrolloSDK could not create app data folder. SDK cannot function without this.")
            }
        }
        
        _database = Database(path: configuration.dataDirectory, targetName: configuration.targetName)
        preferences = Preferences(path: configuration.dataDirectory)
        version = Version(path: configuration.dataDirectory, keychain: keychain)
        
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
        if case FrolloSDKConfiguration.AuthenticationType.oAuth2(_, _, let tokenEndpoint, _) = configuration.authenticationType, let host = tokenEndpoint.host, host.contains(frolloHost) {
            pinToken = true
        }
        
        if configuration.publicKeyPinningEnabled, pinServer || pinToken {
            pinnedKeys = [URL: [SecKey]]()
            
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
                if pinToken, case FrolloSDKConfiguration.AuthenticationType.oAuth2(_, _, let tokenEndpoint, _) = configuration.authenticationType {
                    pinnedKeys?[tokenEndpoint] = [activeKey, backupKey]
                }
            }
        }
        
        Log.logLevel = configuration.logLevel
        
        _authentication = Authentication(serverEndpoint: configuration.serverEndpoint)
        network = Network(serverEndpoint: configuration.serverEndpoint, authentication: _authentication, pinnedPublicKeys: pinnedKeys)
        
        // Setup authentication stack
        switch configuration.authenticationType {
            case .custom(let authenticationDataSource, let authenticationDelegate):
                _authentication.dataSource = authenticationDataSource
                _authentication.delegate = authenticationDelegate
                
            case .oAuth2(let redirectURL, let authorizationEndpoint, let tokenEndpoint, let revokeTokenEndpoint):
                let authService = OAuth2Service(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint, redirectURL: redirectURL, revokeURL: revokeTokenEndpoint, network: network)
                oAuth2Authentication = OAuth2Authentication(keychain: keychain, clientID: configuration.clientID, redirectURL: redirectURL, serverURL: configuration.serverEndpoint, authService: authService, preferences: preferences, delegate: self)
                _authentication.dataSource = oAuth2Authentication
                _authentication.delegate = oAuth2Authentication
        }
        
        service = APIService(serverEndpoint: configuration.serverEndpoint, network: network)
        
        Log.manager.service = service
        
        _aggregation = Aggregation(database: _database, service: service)
        _bills = Bills(database: _database, service: service, aggregation: _aggregation)
        _budgets = Budgets(database: _database, service: service)
        _events = Events(service: service)
        _goals = Goals(database: _database, service: service, aggregation: _aggregation)
        _images = Images(database: _database, service: service)
        _messages = Messages(database: _database, service: service)
        _payDays = PayDays(database: _database, service: service)
        _reports = Reports(database: _database, service: service, aggregation: _aggregation)
        _surveys = Surveys(service: service)
        _userManagement = UserManagement(database: _database, service: service, clientID: configuration.clientID, authentication: oAuth2Authentication, preferences: preferences, delegate: self)
        _notifications = Notifications(events: _events, messages: _messages, userManagement: _userManagement)
        
        _events.delegate = delegate
        _messages.delegate = delegate
        
        // Check for database migration and return progress object if relevant
        if _database.needsMigration() {
            return _database.migrate { error in
                if let migrationError = error {
                    self._database.destroyPersistentStore()
                    self.preferences.reset()
                    
                    completion(.failure(migrationError))
                } else {
                    self._database.setup { error in
                        if let setupError = error {
                            self._database.destroyPersistentStore()
                            self.preferences.reset()
                            
                            completion(.failure(setupError))
                        } else {
                            self._setup = true
                            
                            self.delayedProcessing()
                            
                            completion(.success)
                        }
                    }
                }
            }
        } else {
            _database.setup { error in
                if let setupError = error {
                    self._database.destroyPersistentStore()
                    self.preferences.reset()
                    
                    completion(.failure(setupError))
                } else {
                    self._setup = true
                    
                    self.delayedProcessing()
                    
                    completion(.success)
                }
            }
        }
        
        return nil
    }
    
    /// Process outstanding data
    private func delayedProcessing() {
        if let token = notificationToken {
            notifications.handlePushNotificationToken(token)
            
            notificationToken = nil
        }
    }
    
    // MARK: - Reset
    
    /**
     Reset the SDK. Clears all caches, datbases and keychain entries. Called automatically from logout.
     
     - parameters:
        - completion: Completion handler with option error if something goes wrong (optional)
     */
    public func reset(completionHandler: FrolloSDKCompletionHandler? = nil) {
        Log.debug("SDK Reset Called")
        
        authentication.reset()
        
        internalReset(completionHandler: completionHandler)
    }
    
    /**
     Internal SDK reset
     
     Triggers the internal cleanup of the SDK. Called from public logout/reset methods and also forced logout
     */
    internal func internalReset(completionHandler: FrolloSDKCompletionHandler? = nil) {
        Log.debug("SDK internal reset initiated...")
        
        pauseScheduledRefreshing()
        
        oAuth2Authentication?.reset()
        
        network.reset()
        
        keychain.removeAll()
        
        preferences.reset()
        
        database.reset { error in
            if let resetError = error {
                completionHandler?(.failure(resetError))
            } else {
                completionHandler?(.success)
            }
        }
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
            
            userManagement.updateDevice()
        }
    }
    
    // MARK: - Push Notifications
    
    /**
     Register Push Notification Token
     
     Registers the device token received from APNS to the host to allow for push notifications to be sent
     
     - parameters:
        - token: Raw token data received from APNS to be sent to the host
     */
    public func registerPushNotificationToken(_ token: Data) {
        guard setup else {
            notificationToken = token
            return
        }
        
        notifications.handlePushNotificationToken(token)
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
        aggregation.refreshTransactions()
        aggregation.refreshConsents()
        userManagement.refreshUser()
        messages.refreshUnreadMessages()
        budgets.refreshBudgets(current: true)
    }
    
    /**
     Refresh data from other important APIs that frequently change but are less time sensitive, e.g. bill payments
     */
    private func refreshSecondary() {
        let fromDate = Date().startOfLastMonth()
        let toDate = Date().addingTimeInterval(31622400).endOfMonth()
        
        bills.refreshBillPayments(from: fromDate, to: toDate)
        goals.refreshGoals()
        
    }
    
    /**
     Refresh data from long lived sources which don't change often, e.g. transaction categories, providers
     */
    public func refreshSystem() {
        aggregation.refreshProviders()
        aggregation.refreshTransactionCategories()
        aggregation.refreshCachedMerchants()
        bills.refreshBills()
        userManagement.updateDevice()
    }
    
    // MARK: - Scheduled Refresh
    
    private func resumeScheduledRefreshing() {
        cancelRefreshTimer()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: cacheExpiry, repeats: true, block: { [weak self] (_: Timer) in
            self?.refreshPrimary()
        })
    }
    
    private func pauseScheduledRefreshing() {
        cancelRefreshTimer()
    }
    
    private func cancelRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - OAuth2 Authentication Delegate
    
    internal func authenticationReset() {
        reset()
    }
    
    internal func userAuthenticated() {
        guard setup else {
            return
        }
        
        userManagement.updateDevice()
    }
    
    // MARK: - User Management Delegate
    
    internal func userDeleted() {
        authentication.reset()
        
        internalReset()
    }
    
    /**
     Download data from and endpoint requiring authorization
     
     - parameters:
        - url: The endpoint url to be authorized and from which data is to be downloaded
        - completion: The block that will be executed when the data download is complete(Optional)
     */
    public func downloadData(url: URL, completion: ((Swift.Result<Data, Error>) -> Void)?) {
        service.downloadData(url: url, completion: completion)
    }
    
}
