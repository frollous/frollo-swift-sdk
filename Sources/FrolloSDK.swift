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
    
    //public let preferences = Preferences()
    
    internal let authentication: Authentication
    internal let database: Database
    internal let keychain: Keychain
    internal let network: Network
    internal let preferences: Preferences
    
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
        
        self.authentication = Authentication(database: database, network: network, preferences: preferences)
        
        self.network.delegate = self
    }
    
    public func setup(completionHandler: @escaping (Error?) -> Void) {
        database.setup(completionHandler: completionHandler)
    }
    
//    public func authenticate(authToken: String, completion: FrolloSDKCompletionHandler) {
//        authentication.authenticate(authToken, completion: completion)
//    }
    
    public func logout(completionHandler: @escaping (Error?) -> Void) {
        authentication.logoutUser()
        
        reset()
    }
    
    // MARK: - Logout and Reset
    
    public func reset(completionHandler: ((Error?) -> Void)? = nil) {
        authentication.reset()
        
        keychain.removeAll()
        
        database.reset { (error) in
            completionHandler?(error)
        }
        
        NotificationCenter.default.post(name: FrolloSDK.authenticationChangedNotification, object: self, userInfo: [FrolloSDK.authenticationStatusKey: FrolloSDKAuthenticationStatus.loggedOut])
    }
    
    // MARK: - Network Delegate
    
    internal func forcedLogout() {
        reset()
    }
    
}
