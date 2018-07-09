//
//  NetworkError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class NetworkError: FrolloSDKError {
    
    enum NetworkErrorType: String {
        case connectionFailure
        case invalidSSL
        case unknown
    }
    
    public var debugDescription: String {
        get {
            return debugNetworkErrorDescription()
        }
    }
    public var localizedDescription: String {
        get {
            return localizedNetworkErrorDescription()
        }
    }
    
    internal var systemError: NSError
    internal var type: NetworkErrorType
    
    init(error: NSError) {
        self.systemError = error
        
        switch error.domain {
            case NSStreamSocketSSLErrorDomain:
                type = .invalidSSL
            case NSURLErrorDomain:
                type = .connectionFailure
            default:
                type = .unknown
        }
    }
    
    private func localizedNetworkErrorDescription() -> String {
        switch type {
            case .connectionFailure:
                return Localization.string("Error.Network.ConnectionFailure")
            case .invalidSSL:
                return Localization.string("Error.Network.InvalidSSL")
            default:
                return Localization.string("Error.Network.UnknownError")
        }
    }
    
    private func debugNetworkErrorDescription() -> String {
        return "NetworkError." + type.rawValue + ": " + localizedDescription + " | " + systemError.debugDescription
    }
    
}
