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
    internal var sessionManager: Session!
    
    private let APIVersion = "2.14"
    private var encoder: JSONEncoder?
    
    /**
     Initialise a network stack pointing to an API at a specific URL
     
     - parameters:
     - serverEndpoint: Base URL endpoint of the API, e.g. https://api.example.com/v1/
     - authentication: The authentication service for authenticating requests and managing tokens
     - pinnedPublicKeys: Dictionary of hosts and their public keys to pin the server's certificates against (Optional)
     
     - warning: If using certificate pinning make sure you pin a second public key as a backup in case the production private/public key pair becomes compromised. Failure to do this will render your app unusable until updated with the new public/private key pair.
     */
    internal init(serverEndpoint: URL, authentication: Authentication, encoder: JSONEncoder? = nil, pinnedPublicKeys: [URL: [SecKey]]? = nil) {
        self.authentication = authentication
        self.serverURL = serverEndpoint
        self.encoder = encoder
        
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
        
        #if !SWIFT_PACKAGE
        let sdkVersion = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as! String
        let sdkBuild = Bundle(for: Network.self).object(forInfoDictionaryKey: VersionConstants.bundleVersion) as! String
        #else
        let sdkVersion = "4.9.2"
        let sdkBuild = "492"
        #endif
        
        let appBuild = Bundle.main.object(forInfoDictionaryKey: VersionConstants.bundleVersion) as? String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: VersionConstants.bundleShortVersion) as? String
        let bundleID = Bundle.module.bundleIdentifier!
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
        
        var serverTrustManager: ServerTrustManager?
        
        // Public key pinning
        if let pinnedKeys = pinnedPublicKeys, !pinnedKeys.isEmpty {
            var serverTrustPolicies: [String: ServerTrustEvaluating] = [:]
            
            pinnedKeys.forEach { item in
                if let host = item.key.host {
                    serverTrustPolicies[host] = PublicKeysTrustEvaluator(keys: item.value, validateHost: true)
                }
            }
            
            serverTrustManager = ServerTrustManager(evaluators: serverTrustPolicies)
        }
        
        super.init()
        
        self.sessionManager = Session(configuration: configuration, delegate: self, interceptor: authentication, serverTrustManager: serverTrustManager)
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
    
    internal func contentRequest<T: Codable>(url: URL, method: HTTPMethod, content: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, userOtp: String? = nil) -> URLRequest? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let jsonEncoder = encoder ?? JSONEncoder()
        
        if let encodingStrategy = dateEncodingStrategy {
            jsonEncoder.dateEncodingStrategy = encodingStrategy
        }
        
        do {
            let requestData = try jsonEncoder.encode(content)
            
            urlRequest.addValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
            urlRequest.httpBody = requestData
            if let otp = userOtp {
                urlRequest.addValue(otp, forHTTPHeaderField: HTTPHeader.otp.rawValue)
            }
            
            return urlRequest
        } catch {
            error.logError()
            
            return nil
        }
    }
    
    // MARK: - Response Handling
    
    internal func handleFailure<T: ResponseError>(type: T.Type, response: DataResponse<Data, AFError>, error: Error, completion: (_: FrolloSDKError) -> Void) {
        let dataError = error as? AFError
        if let parsedError = dataError?.underlyingError as? DataError, parsedError.type == .authentication, parsedError.subType == .missingRefreshToken {
            authentication.tokenInvalidated()
            
            reset()
            
            completion(parsedError)
        } else if let parsedError = dataError?.underlyingError as? FrolloSDKError {
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
            let afError = error.asAFError
            let systemError = afError?.underlyingError
            let networkError = NetworkError(error: systemError as NSError?)
            completion(networkError)
        }
    }
    
    internal func handleResponse<T: Codable, U: ResponseError>(type: T.Type, errorType: U.Type, response: DataResponse<Data, AFError>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<T>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(T.self, from: value)
                    
                    completion(.success(apiResponse))
                } catch {
                    error.logError()
                    
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
    
    internal func handleArrayResponse<T: Codable, U: ResponseError>(type: T.Type, errorType: U.Type, response: DataResponse<Data, AFError>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<[T]>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(FailableCodableArray<T>.self, from: value)
                    
                    completion(.success(apiResponse.elements))
                } catch {
                    error.logError()
                    
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
    
    internal func handlePaginatedArrayResponse<T: Codable, U: ResponseError>(type: T.Type, errorType: U.Type, response: DataResponse<Data, AFError>, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Milliseconds), completion: RequestCompletion<APIPaginatedResponse<T>>) {
        switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                
                do {
                    let apiResponse = try decoder.decode(APIPaginatedResponse<T>.self, from: value)
                    completion(.success(apiResponse))
                } catch {
                    error.logError()
                    
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
    
    internal func handleEmptyResponse<T: ResponseError>(errorType: T.Type, response: DataResponse<Data, AFError>, completion: NetworkCompletion) {
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
