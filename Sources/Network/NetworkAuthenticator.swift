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

internal class NetworkAuthenticator: RequestAdapter, RequestRetrier {
    
    internal typealias TokenRequestCompletion = (_: Swift.Result<OAuthTokenResponse, Error>) -> Void
    
    internal struct KeychainKey {
        static let accessToken = "accessToken"
        static let accessTokenExpiry = "accessTokenExpiry"
    }
    
    /// Access Token used with the API
    internal var accessToken: String?
    
    /// Expiry date of the access token, typically 30 minutes after issue
    internal var expiryDate: Date?
    
    internal weak var authentication: Authentication?
    
    private let bearerFormat = "Bearer %@"
    private let keychain: Keychain
    private let lock = NSLock()
    private let maxRateLimitCount: Double = 10
    private let requestQueue = DispatchQueue(label: "FrolloSDK.APIAuthenticatorRequestQueue", qos: .userInitiated, attributes: .concurrent)
    private let responseQueue = DispatchQueue(label: "FrolloSDK.APIAuthenticatorResponseQueue", qos: .userInitiated, attributes: .concurrent)
    private let serverURL: URL
    private let timeInterval5Minutes: Double = 300
    
    private var rateLimitCount: Double = 0
    private var refreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    init(serverEndpoint: URL, keychain: Keychain) {
        self.serverURL = serverEndpoint
        self.keychain = keychain
        
        loadTokens()
    }
    
    internal func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let url = urlRequest.url, url.absoluteString.hasPrefix(serverURL.absoluteString)
        else {
            return urlRequest
        }
        
        var request = urlRequest
        
        if let relativePath = request.url?.relativePath, !(relativePath.contains(UserEndpoint.register.path) || relativePath.contains(UserEndpoint.resetPassword.path) || relativePath.contains(UserEndpoint.migrate.path)) {
            do {
                let adaptedRequest = try validateAndAppendAccessToken(request: request)
                return adaptedRequest
            } catch {
                throw error
            }
        }
        
        return urlRequest
    }
    
    // MARK: - Retry Requests
    
    internal func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard let responseError = error as? AFError
        else {
            completion(false, 0)
            return
        }
        
        lock.lock(); defer { lock.unlock() }
        
        switch responseError {
            case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
                switch code {
                    case 401:
                        if let data = request.delegate.data {
                            let apiError = APIError(statusCode: code, response: data)
                            switch apiError.type {
                                case .invalidAccessToken:
                                    // Refresh the token
                                    if request.retryCount < 3 {
                                        requestsToRetry.append(completion)
                                        
                                        refreshTokens()
                                    } else {
                                        completion(false, 0)
                                    }
                                default:
                                    completion(false, 0)
                            }
                        } else {
                            completion(false, 0)
                        }
                    case 429:
                        rateLimitCount = min(rateLimitCount + 1, maxRateLimitCount)
                        
                        completion(true, rateLimitCount * 3)
                    default:
                        completion(false, 0)
                }
            default:
                completion(false, 0)
        }
    }
    
    // MARK: - Auth Headers
    
    internal func validateAndAppendAccessToken(request: URLRequest) throws -> URLRequest {
        if !validToken() {
            lock.lock()
            
            let semaphore = DispatchSemaphore(value: 0)
            
            requestsToRetry.append { (_: Bool, _: TimeInterval) in
                // Unblock once token has updated
                semaphore.signal()
            }
            
            refreshTokens()
            
            lock.unlock()
            
            semaphore.wait()
        }
        
        guard let token = accessToken
        else {
            throw DataError(type: .authentication, subType: .missingAccessToken)
        }
        
        var urlRequest = request
        
        let bearer = String(format: bearerFormat, token)
        urlRequest.setValue(bearer, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        
        return urlRequest
    }
    
    // MARK: - Token Handling
    
    /**
     Cache access token and save token to the keychain
     
     - parameters:
         - accessToken: Access token
         - expiry: Access token expiry date
     */
    internal func saveAccessToken(_ accessToken: String, expiry: Date) {
        self.accessToken = accessToken
        expiryDate = expiry
        
        keychain[KeychainKey.accessToken] = accessToken
        
        let expirySeconds = String(expiry.timeIntervalSince1970)
        keychain[KeychainKey.accessTokenExpiry] = expirySeconds
    }
    
    /**
     Clear the cached tokens and delete any keychain persisted tokens
     */
    internal func clearTokens() {
        accessToken = nil
        expiryDate = nil
        
        keychain.removeAll()
    }
    
    internal func refreshTokens() {
        guard !refreshing
        else {
            return
        }
        
        refreshing = true
        
        guard let auth = authentication
        else {
            requestsToRetry.forEach { $0(false, 0.0) }
            requestsToRetry.removeAll()
            
            return
        }
        
        auth.refreshTokens { result in
            switch result {
                case .failure(let error):
                    if let apiError = error as? APIError, apiError.type == .invalidRefreshToken {
                        self.clearTokens()
                        
                        Log.error("Refreshing token failed due to authorisation error." + apiError.localizedDescription)
                    }
                    
                    self.requestsToRetry.forEach { $0(false, 0.0) }
                    self.requestsToRetry.removeAll()
                case .success:
                    self.requestsToRetry.forEach { $0(true, 0.0) }
                    self.requestsToRetry.removeAll()
            }
            
            self.refreshing = false
        }
    }
    
    private func validToken() -> Bool {
        guard accessToken != nil,
            let date = expiryDate
        else {
            return false
        }
        
        let adjustedExpiryDate = date.addingTimeInterval(-timeInterval5Minutes)
        let nowDate = Date()
        
        if nowDate.compare(adjustedExpiryDate) == .orderedAscending {
            return true
        }
        
        return false
    }
    
    private func loadTokens() {
        accessToken = keychain[KeychainKey.accessToken]
        
        if let expiryTime = keychain[KeychainKey.accessTokenExpiry], let expirySeconds = TimeInterval(expiryTime) {
            expiryDate = Date(timeIntervalSince1970: expirySeconds)
        }
    }
    
}
