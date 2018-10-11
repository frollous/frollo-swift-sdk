//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

public typealias FrolloSDKCompletionHandler = (Error?) -> Void

class FrolloSDK: NetworkDelegate {
    
    /**
     Notification triggered when ever the authentication status of the SDK changes. Observe this notification to detect if the SDK user has authenticated or been logged out.
    */
    public static let authenticationChangedNotification = Notification.Name(rawValue: "FrolloSDK.authenticationChangedNotification")
    
    /**
     User info key for authentication status sent with `authenticationChangedNotification` notifications.
    */
    public static let authenticationStatusKey = "FrolloSDKKey.authenticationStatus"
    
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
    
    internal let aggregation: Aggregation
    internal let authentication: Authentication
    internal let database: Database
    internal let keychain: Keychain
    internal let network: Network
    internal let preferences: Preferences
    
    internal var refreshTimer: Timer?
    
    // MARK: - Setup
    
    public init(serverURL: URL) {
        // Create data folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: FrolloSDK.dataFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: FrolloSDK.dataFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("FrolloSDK could not create app data folder. SDK cannot function without this.")
            }
        }
        
        self.database = Database(path: FrolloSDK.dataFolderURL)
        self.keychain = Keychain(service: FrolloSDKConstants.keychainService)
        self.network = Network(serverURL: serverURL, keychain: keychain)
        self.preferences = Preferences(path: FrolloSDK.dataFolderURL)
        
        self.aggregation = Aggregation(database: database, network: network)
        self.authentication = Authentication(database: database, network: network, preferences: preferences)
        
        self.network.delegate = self
    }
    
    public func setup(completionHandler: @escaping (Error?) -> Void) {
        database.setup(completionHandler: completionHandler)
    }
    
//    public func authenticate(authToken: String, completion: FrolloSDKCompletionHandler) {
//        authentication.authenticate(authToken, completion: completion)
//    }
    
    // MARK: - Logout and Reset
    
    public func logout(completionHandler: @escaping (Error?) -> Void) {
        authentication.logoutUser()
        
        reset()
    }
    
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
    
    public func applicationDidEnterBackground() {
        pauseScheduledRefreshing()
    }
    
    public func applicationWillEnterForeground() {
        resumeScheduledRefreshing()
    }
    
    // MARK: - Refresh
    
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
