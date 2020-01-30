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

import Foundation

import Alamofire

internal typealias NetworkCompletion = (_: Swift.Result<Data, Error>) -> Void
internal typealias RequestCompletion<T> = (_: Swift.Result<T, Error>) -> Void

class Network: SessionDelegate {
    
    #if !os(watchOS)
    public let reachability: NetworkReachabilityManager
    #endif
    
    /// Base URL of the API
    internal let serverURL: URL
    
    internal var authentication: Authentication
    internal var sessionManager: SessionManager!
    
    private let APIVersion = "2.7"
    
    /**
     Initialise a network stack pointing to an API at a specific URL
     
     - parameters:
     - serverEndpoint: Base URL endpoint of the API, e.g. https://api.example.com/v1/
     - authentication: The authentication service for authenticating requests and managing tokens
     - pinnedPublicKeys: Dictionary of hosts and their public keys to pin the server's certificates against (Optional)
     
     - warning: If using certificate pinning make sure you pin a second public key as a backup in case the production private/public key pair becomes compromised. Failure to do this will render your app unusable until updated with the new public/private key pair.
     */
    internal init(serverEndpoint: URL, authentication: Authentication, pinnedPublicKeys: [URL: [SecKey]]? = nil) {
        self.authentication = authentication
        self.serverURL = serverEndpoint
        
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
        
        let sdkBuild = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleVersion) as! String
        let sdkVersion = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        let appBuild = Bundle.main.object(forInfoDictionaryKey: VersionConstants.bundleVersion) as? String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as? String
        let bundleID = Bundle(for: Network.self).bundleIdentifier!
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        
        #if !os(watchOS)
        reachability = NetworkReachabilityManager(host: serverURL.host!)!
        #endif
        
        var versionString = String(format: "SDK%@-B%@", arguments: [sdkVersion, sdkBuild])
        if let version = appVersion, let build = appBuild {
            let appVersionString = String(format: "|APP%@-B%@", arguments: [version, build])
            versionString.append(appVersionString)
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        configuration.httpAdditionalHeaders = [HTTPHeader.apiVersion.rawValue: APIVersion,
                                               HTTPHeader.bundleID.rawValue: bundleID,
                                               HTTPHeader.deviceVersion.rawValue: osVersion + systemVersion,
                                               HTTPHeader.softwareVersion.rawValue: versionString]
        
        var serverTrustManager: ServerTrustPolicyManager?
        
        // Public key pinning
        if let pinnedKeys = pinnedPublicKeys, !pinnedKeys.isEmpty {
            var serverTrustPolicies: [String: ServerTrustPolicy] = [:]
            
            pinnedKeys.forEach { item in
                if let host = item.key.host {
                    serverTrustPolicies[host] = ServerTrustPolicy.pinPublicKeys(publicKeys: item.value, validateCertificateChain: true, validateHost: true)
                }
            }
            
            serverTrustManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        }
        
        super.init()
        
        self.sessionManager = SessionManager(configuration: configuration, delegate: self, serverTrustPolicyManager: serverTrustManager)
        sessionManager.adapter = authentication
        sessionManager.retrier = authentication
    }
    
    // MARK: - Reset
    
    internal func reset() {
        Log.debug("SDK Network reset initiated...")
        
        sessionManager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
        
        URLCache.shared.removeAllCachedResponses()
        
        authentication.reset()
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
    
    internal func handleFailure<T: ResponseError>(type: T.Type, response: DataResponse<Data>, error: Error, completion: (_: FrolloSDKError) -> Void) {
        if let parsedError = error as? DataError, parsedError.type == .authentication, parsedError.subType == .missingRefreshToken {
            authentication.tokenInvalidated()
            
            reset()
            
            completion(parsedError)
        } else if let parsedError = error as? FrolloSDKError {
            completion(parsedError)
        } else if let statusCode = response.response?.statusCode {
            let responseError = T(statusCode: statusCode, response: response.data)
            
            if let apiError = responseError as? APIError {
                let clearTokenStatuses: [APIError.APIErrorType] = [.invalidRefreshToken, .suspendedDevice, .suspendedUser, .otherAuthorisation, .accountLocked]
                
                if clearTokenStatuses.contains(apiError.type) {
                    authentication.tokenInvalidated()
                    
                    reset()
                }
            } else if let oAuth2Error = responseError as? OAuth2Error {
                let clearTokenStatuses: [OAuth2Error.OAuth2ErrorType] = [.invalidClient, .invalidRequest, .invalidGrant, .invalidScope, .unauthorizedClient, .unsupportedGrantType, .serverError]
                
                if clearTokenStatuses.contains(oAuth2Error.type) {
                    authentication.tokenInvalidated()
                    
                    reset()
                }
            }
            
            completion(responseError)
        } else {
            let systemError = error as NSError
            let networkError = NetworkError(error: systemError)
            completion(networkError)
        }
    }
    
    internal func handleResponse<T: Codable, U: ResponseError>(type: T.Type, errorType: U.Type, response: DataResponse<Data>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<T>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(T.self, from: value)
                    
                    completion(.success(apiResponse))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .api, subType: .invalidData)
                    dataError.systemError = error
                    completion(.failure(dataError))
                }
            case .failure(let error):
                handleFailure(type: errorType, response: response, error: error) { processedError in
                    completion(.failure(processedError))
                }
        }
    }
    
    internal func handleArrayResponse<T: Codable, U: ResponseError>(type: T.Type, errorType: U.Type, response: DataResponse<Data>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<[T]>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(FailableCodableArray<T>.self, from: value)
                    
                    completion(.success(apiResponse.elements))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .api, subType: .invalidData)
                    dataError.systemError = error
                    completion(.failure(dataError))
                }
            case .failure(let error):
                handleFailure(type: errorType, response: response, error: error) { processedError in
                    completion(.failure(processedError))
                }
        }
    }
    
    internal func handlePaginatedArrayResponse<T: Codable, U: ResponseError>(type: T.Type, errorType: U.Type, response: DataResponse<Data>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<APIPaginatedResponse<T>>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(APIPaginatedResponse<T>.self, from: value)
                    completion(.success(apiResponse))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .api, subType: .invalidData)
                    dataError.systemError = error
                    completion(.failure(dataError))
                }
            case .failure(let error):
                handleFailure(type: errorType, response: response, error: error) { processedError in
                    completion(.failure(processedError))
                }
        }
    }
    
    internal func handlePaginatedTransactionArrayResponse<U: ResponseError>(errorType: U.Type, response: DataResponse<Data>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<APITransactionPaginatedResponse>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(APITransactionPaginatedResponse.self, from: value)
                    completion(.success(apiResponse))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .api, subType: .invalidData)
                    dataError.systemError = error
                    completion(.failure(dataError))
                }
            case .failure(let error):
                handleFailure(type: errorType, response: response, error: error) { processedError in
                    completion(.failure(processedError))
                }
        }
    }
    
    internal func handleEmptyResponse<T: ResponseError>(errorType: T.Type, response: DataResponse<Data>, completion: NetworkCompletion) {
        switch response.result {
            case .success:
                completion(.success(Data()))
            case .failure(let error):
                handleFailure(type: errorType, response: response, error: error) { processedError in
                    completion(.failure(processedError))
                }
        }
    }
    
}
