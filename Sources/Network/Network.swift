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
    
    internal typealias NetworkCompletion = (_ data: Data?, _ error: FrolloSDKError?) -> Void
    
    struct HTTPHeader {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let etag = "Etag"
        static let userAgent = "User-Agent"
        static let xBackground = "X-Background"
    }
    
    public let reachability: NetworkReachabilityManager
    
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    internal let serverURL: URL
    
    internal var authenticator: NetworkAuthenticator!
    internal var sessionManager: SessionManager!
    
    private let APIVersion = "1.15"
    
    internal init(serverURL: URL, keychain: Keychain, pinnedPublicKeys: [SecKey]? = nil) {
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
        
        authenticator = NetworkAuthenticator(network: self, keychain: keychain)
        
        self.sessionManager = SessionManager(configuration: configuration, delegate: self, serverTrustPolicyManager: serverTrustManager)
        self.sessionManager.adapter = authenticator
        self.sessionManager.retrier = authenticator
    }
    
    internal func handleFailure(response: DataResponse<Data>, completion: (_: FrolloSDKError?) -> Void) {
        switch response.result {
            case .success:
                completion(nil)
            case .failure(let error):
                if let parsedError = error as? FrolloSDKError {
                    completion(parsedError)
                } else if let statusCode = response.response?.statusCode {
                    let apiError = APIError(statusCode: statusCode, response: response.data)
                    
                    let clearTokenStatuses: [APIError.APIErrorType] = [.invalidRefreshToken, .suspendedDevice, .suspendedUser, .invalidUsernamePassword, .otherAuthorisation]
                    if clearTokenStatuses.contains(apiError.type) {
                        authenticator.clearTokens()
                    }
                    
                    completion(apiError)
                } else {
                    let systemError = error as NSError
                    let networkError = NetworkError(error: systemError)
                    completion(networkError)
                }
        }
    }
    
    internal func handleTokens(response: DataResponse<Data>, completion: NetworkCompletion) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let tokenResponse = try decoder.decode(APITokenResponse.self, from: value)
                    
                    authenticator.saveTokens(refresh: tokenResponse.refreshToken, access: tokenResponse.accessToken, expiry: tokenResponse.accessTokenExpiry)
                } catch {
                    Log.error(error.localizedDescription)
                    
                    authenticator.clearTokens()
                    
                    let dataError = DataError(type: .authentication, subType: .missingAccessToken)
                    completion(nil, dataError)
                    
                    return
                }
                
                completion(value, nil)
            case .failure:
                handleFailure(response: response) { (error) in
                    completion(nil, error)
                }
        }
    }
    
}
