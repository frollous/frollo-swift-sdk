//
//  Network.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

class Network: SessionDelegate {
    
    struct HTTPHeader {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let etag = "Etag"
        static let userAgent = "User-Agent"
    }
    
    public let reachability: NetworkReachabilityManager
    
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    internal let serverURL: URL
    
    internal var sessionManager: SessionManager!
    
    private let APIVersion = "1.15"
    
    internal init(serverURL: URL, pinnedPublicKeys: [SecKey]? = nil) {
        self.serverURL = serverURL
        
        #if os(macOS)
            let osVersion = "macOS"
        #elseif os(iOS)
            let osVersion = "iOS"
        #elseif os(tvOS)
            let osVersion = "tvOS"
        #elseif os(watchOS)
            let osVersion = "watchOS"
        #else
            let osVersion = "unknownOS"
        #endif
        
        let appBuild = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleVersion) as! String
        let appVersion = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let userAgent = String(format: "%@|V%@|B%@|%@%@|API%@", arguments: [Bundle(for: Network.self).bundleIdentifier!, appVersion, appBuild, osVersion, systemVersion, APIVersion])
        
        reachability = NetworkReachabilityManager(host: serverURL.host!)!
        
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        configuration.httpAdditionalHeaders = [HTTPHeader.userAgent: userAgent]
        
        var serverTrustManager: ServerTrustPolicyManager?
        
        // Public key pinning
        if let pinnedKeys = pinnedPublicKeys {
            let serverTrustPolicies: [String: ServerTrustPolicy] = [serverURL.host!: ServerTrustPolicy.pinPublicKeys(publicKeys: pinnedKeys, validateCertificateChain: true, validateHost: true)]
            serverTrustManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        }
        
        super.init()
        
        self.sessionManager = SessionManager(configuration: configuration, delegate: self, serverTrustPolicyManager: serverTrustManager)
        //self.sessionManager.adapter = self.authenticationHandler
        //self.sessionManager.retrier = self.authenticationHandler
    }
    
    
    
}
