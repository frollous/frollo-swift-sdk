//
//  NetworkError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 5/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 Network Error
 
 Error occuring at the network layer
 */
public class NetworkError: FrolloSDKError {
    
    /**
     Network error type
     
     Indicates the type of error
    */
    public enum NetworkErrorType: String {
        
        /// Connection failure - usually poor connectivity
        case connectionFailure
        
        /// Invalid SSL - TLS public key pinning has failed or the certificate provided is invalid. Usually indicates a MITM attack
        case invalidSSL
        
        /// Unknown
        case unknown
        
    }
    
    /// Debug description
    public var debugDescription: String {
        get {
            return debugNetworkErrorDescription()
        }
    }
    
    /// Error description
    public var errorDescription: String? {
        get {
            return localizedNetworkErrorDescription()
        }
    }
    
    /// Underlying system error that triggered this error
    public var systemError: NSError
    
    /// Type of error for common scenarios
    public var type: NetworkErrorType
    
    internal init(error: NSError) {
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
    
    // MARK: - Error description handling
    
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
