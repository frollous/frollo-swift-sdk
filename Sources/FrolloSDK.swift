//
//  FrolloSDK.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 26/6/18.
//

import Foundation

public typealias FrolloSDKCompletionHandler = (Error?) -> Void

class FrolloSDK {
    
    public let preferences = Preferences()
    
//    internal let authentication = Authentication()
    internal let database = Database()
    internal let network: Network
    
    public init(serverURL: URL) {
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
