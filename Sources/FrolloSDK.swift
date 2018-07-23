//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

public typealias FrolloSDKCompletionHandler = (Error?) -> Void

class FrolloSDK {
    
    struct FrolloSDKConstants {
        static let dataFolder = "FrolloSDKData"
    }
    
    static internal let dataFolderURL: URL = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        var appDataURL = urls[0]
        appDataURL.appendPathComponent(FrolloSDKConstants.dataFolder)
        return appDataURL
    }()
    
    //public let preferences = Preferences()
    
//    internal let authentication = Authentication()
    internal let database: Database
    internal let network: Network
    
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
        self.network = Network(serverURL: serverURL)
    }
    
    public func setup(completionHandler: @escaping (Error?) -> Void) {
        database.setup(completionHandler: completionHandler)
    }
    
//    public func authenticate(authToken: String, completion: FrolloSDKCompletionHandler) {
//        authentication.authenticate(authToken, completion: completion)
//    }
    
    public func reset(completionHandler: @escaping (Error?) -> Void) {
        database.reset(completionHandler: completionHandler)
    }
    
}
