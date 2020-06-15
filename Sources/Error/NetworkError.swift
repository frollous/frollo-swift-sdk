//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Alamofire
import Foundation

extension Error {
    var domain: String {
        return (self as NSError).domain
    }
}

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
        return debugNetworkErrorDescription()
    }
    
    /// Error description
    public var errorDescription: String? {
        return localizedNetworkErrorDescription()
    }
    
    /// Underlying system error that triggered this error
    public var systemError: NSError
    
    /// Type of error for common scenarios
    public var type: NetworkErrorType
    
    internal init(error: NSError) {
        self.systemError = error
        
        switch error.domain {
            case NSStreamSocketSSLErrorDomain:
                self.type = .invalidSSL
            case NSURLErrorDomain:
                self.type = .connectionFailure
            default:
                self.type = .unknown
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
