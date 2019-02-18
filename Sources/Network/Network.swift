//
//  Network.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 28/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

protocol NetworkDelegate: class {
    
    func forcedLogout()
    
}

class Network: SessionDelegate {
    
    internal typealias NetworkCompletion = (_: Result<Data, FrolloSDKError>) -> Void
    internal typealias RequestCompletion<T> = (_: Result<T, Error>) -> Void
    
    internal enum HTTPHeader: String, CaseIterable {
        case apiVersion = "X-Api-Version"
        case authorization = "Authorization"
        case background = "X-Background"
        case bundleID = "X-Bundle-Id"
        case contentType = "Content-Type"
        case deviceVersion = "X-Device-Version"
        case etag = "Etag"
        case softwareVersion = "X-Software-Version"
        case userAgent = "User-Agent"
    }
    
    #if !os(watchOS)
    public let reachability: NetworkReachabilityManager
    #endif
    
    /**
     Asynchronous queue all network requests are executed from
    */
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    /**
     Asynchornous queue all network responses are executed on
    */
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    /**
     Base URL of the API
    */
    internal let serverURL: URL
    
    internal weak var delegate: NetworkDelegate?
    
    internal var authenticator: NetworkAuthenticator!
    internal var sessionManager: SessionManager!
    
    private let APIVersion = "2.0"
    
    /**
     Initialise a network stack pointing to an API at a specific URL
     
     - parameters:
        - serverURL: Base URL of the API, e.g. https://api.example.com/v1/
        - keychain: Keychain service to store access and refresh tokens
        - pinnedPublicKeys: Array of public keys to pin the server's certificates against (Optional)
     
        - warning: If using certificate pinning make sure you pin a second public key as a backup in case the production private/public key pair becomes compromised. Failure to do this will render your app unusable until updated with the new public/private key pair.
    */
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
        let bundleID = Bundle(for: Network.self).bundleIdentifier!
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let userAgent = String(format: "%@|SDK%@|B%@|%@%@|API%@", arguments: [bundleID, appVersion, appBuild, osVersion, systemVersion, APIVersion])
        
        #if !os(watchOS)
        reachability = NetworkReachabilityManager(host: serverURL.host!)!
        #endif
        
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        configuration.httpAdditionalHeaders = [HTTPHeader.apiVersion.rawValue: APIVersion,
                                               HTTPHeader.bundleID.rawValue: bundleID,
                                               HTTPHeader.deviceVersion.rawValue: osVersion + systemVersion,
                                               HTTPHeader.softwareVersion.rawValue: String(format: "SDK%@-B%@", arguments: [appVersion, appBuild]),
                                               HTTPHeader.userAgent.rawValue: userAgent]
        
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
    
    // MARK: - Reset
    
    internal func reset() {
        sessionManager.session.getAllTasks { (tasks) in
            tasks.forEach { $0.cancel() }
        }
        
        URLCache.shared.removeAllCachedResponses()
        
        authenticator.clearTokens()
    }
    
    // MARK: - Requests
    
    internal func contentRequest<T: Codable>(url: URL, method: HTTPMethod, content: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil) -> URLRequest? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let encoder = JSONEncoder()
        
        if let encodingStrategy = dateEncodingStrategy {
            encoder.dateEncodingStrategy = encodingStrategy
        }
        
        do {
            let requestData = try encoder.encode(content)
            
            urlRequest.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
            urlRequest.httpBody = requestData
            
            return urlRequest
        } catch {
            Log.error(error.localizedDescription)
            
            return nil
        }
    }
    
    // MARK: - Response Handling
    
    internal func handleFailure(response: DataResponse<Data>, error: Error, completion: (_: FrolloSDKError) -> Void) {
        if let parsedError = error as? DataError, parsedError.type == .authentication, parsedError.subType == .missingRefreshToken {
            reset()
            
            delegate?.forcedLogout()
            
            completion(parsedError)
        } else if let parsedError = error as? FrolloSDKError {
            completion(parsedError)
        } else if let statusCode = response.response?.statusCode {
            let apiError = APIError(statusCode: statusCode, response: response.data)
            
            let clearTokenStatuses: [APIError.APIErrorType] = [.invalidRefreshToken, .suspendedDevice, .suspendedUser, .otherAuthorisation]
            if clearTokenStatuses.contains(apiError.type) {
                reset()
                
                delegate?.forcedLogout()
            }
            
            completion(apiError)
        } else {
            let systemError = error as NSError
            let networkError = NetworkError(error: systemError)
            completion(networkError)
        }
    }
    
    internal func handleResponse<T: Codable>(type: T.Type, response: DataResponse<Data>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<T>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(T.self, from: value)
                    
                    completion(.success(apiResponse))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .unknown, subType: .unknown)
                    completion(.failure(dataError))
                }
            case .failure(let error):
                self.handleFailure(response: response, error: error) { (processedError) in
                    completion(.failure(processedError))
                }
        }
    }
    
    internal func handleArrayResponse<T: Codable>(type: T.Type, response: DataResponse<Data>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<[T]>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(FailableCodableArray<T>.self, from: value)
                    
                    completion(.success(apiResponse.elements))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .unknown, subType: .unknown)
                    completion(.failure(dataError))
                }
            case .failure(let error):
                self.handleFailure(response: response, error: error) { (processedError) in
                    completion(.failure(processedError))
                }
            }
    }
    
    internal func handleEmptyResponse(response: DataResponse<Data>, completion: NetworkCompletion) {
        switch response.result {
            case .success:
                completion(.success(Data()))
            case .failure(let error):
                self.handleFailure(response: response, error: error) { (processedError) in
                    completion(.failure(processedError))
                }
        }
    }
    
    internal func handleTokens(response: DataResponse<Data>) -> FrolloSDKError? {
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
                    
                    return DataError(type: .authentication, subType: .missingAccessToken)
                }
            case .failure:
                break
        }
        
        return nil
    }
    
}
