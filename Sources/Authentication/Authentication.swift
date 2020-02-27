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

/**
 Access token
 
 Represents an access token and the corresponding expiry date if possible
 */
public protocol AccessToken {
    
    /// Expiry date of the token (Optional)
    var expiryDate: Date? { get }
    
    /// Raw token value
    var token: String { get }
    
}

/**
 Authentication Data Source
 
 Data source for the authentication class to retrieve access tokens from.
 This must be implemented by custom authentication implementations.
 */
public protocol AuthenticationDataSource: AnyObject {
    
    /// Access token to use for authorisation if available. If this is not available network requests will not proceed
    var accessToken: AccessToken? { get }
    
    /// Time in seconds the access token should pre-emptively be refreshed before it expires. Optional, otherwise token will be refreshed on a 401
    var preemptiveRefreshTime: TimeInterval? { get }
    
}

/**
 Authentication Delegate
 
 Called by the authentication class to notify the implementing app of issues with authentication.
 This must be implemented by custom authentication implementations.
 */
public protocol AuthenticationDelegate: AnyObject {
    
    /**
     Access Token Expired
     
     Alerts the authentication handler to an expired access token that needs refreshing
     
     - parameters:
        - completion: Completion handler that must be called when the access token has been refreshed. Indicates if the refresh was successful or not.
     */
    func accessTokenExpired(completion: @escaping (Bool) -> Void)
    
    /**
     Access Token Invalid
     
     The host has rejected the access token and the user should be re-authenticated
     */
    func accessTokenInvalid()
    
}

/**
 Authentication
 
 Manages authentication within the SDK
 */
public class Authentication: RequestAdapter, RequestRetrier {
    
    internal var dataSource: AuthenticationDataSource?
    internal var delegate: AuthenticationDelegate?
    
    private let bearerFormat = "Bearer %@"
    private let lock = NSLock()
    private let maxRateLimitCount: Double = 10
    private let requestQueue = DispatchQueue(label: "FrolloSDK.APIAuthenticatorRequestQueue", qos: .userInitiated, attributes: .concurrent)
    private let responseQueue = DispatchQueue(label: "FrolloSDK.APIAuthenticatorResponseQueue", qos: .userInitiated, attributes: .concurrent)
    private let serverURL: URL
    
    private var rateLimitCount: Double = 0
    private var refreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    init(serverEndpoint: URL) {
        self.serverURL = serverEndpoint
    }
    
    // MARK: - Authentication Status
    
    internal func reset() {
        Log.debug("SDK Authentication reset initiated...")
        
        cancelRetryRequests()
    }
    
    internal func tokenInvalidated() {
        delegate?.accessTokenInvalid()
    }
    
    // MARK: - Authorize Network Requests
    
    /**
     Adapts the request with the authorisation header. Only works if `serverURL` matches.
     
     - parameters:
        - urlRequest: The request to be authorized
     */
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let url = urlRequest.url, url.host == serverURL.host
        else {
            return urlRequest
        }
        
        let request = urlRequest
        
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
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        guard let url = urlRequest.url, url.host == serverURL.host
        else {
            completion(.success(urlRequest))
            return
        }
        
        let request = urlRequest
        
        if let relativePath = request.url?.relativePath, !(relativePath.contains(UserEndpoint.register.path) || relativePath.contains(UserEndpoint.resetPassword.path) || relativePath.contains(UserEndpoint.migrate.path)) {
            do {
                let adaptedRequest = try validateAndAppendAccessToken(request: request)
                completion(.success(adaptedRequest))
            } catch {
                completion(.failure(error))
            }
        }
        
        completion(.success(urlRequest))
        
    }
    
    // MARK: - Retry Requests
    
    /**
     Determines whether the `Request` should be retried by calling the `completion` closure.
     
     This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
     to be retried. The one requirement is that the completion closure is called to ensure the request is properly
     cleaned up after.
     
     - Parameters:
       - request:    `Request` that failed due to the provided `Error`.
       - session:    `Session` that produced the `Request`.
       - error:      `Error` encountered while executing the `Request`.
       - completion: Completion closure to be executed when a retry decision has been determined.
     */
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let responseError = error as? AFError
        else {
            return completion(.doNotRetryWithError(error))
        }
        
        lock.lock(); defer { lock.unlock() }
        
        switch responseError {
            case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
                switch code {
                    case 401:
                        
                        if let data = request.response?.statusCode {
                            let apiError = APIError(statusCode: code, response: data)
                            switch apiError.type {
                                case .invalidAccessToken:
                                    // Refresh the token
                                    if request.retryCount < 3 {
                                        requestsToRetry.append(completion)
                                        
                                        refreshTokens()
                                    } else {
                                        completion(.doNotRetryWithError(error))
                                    }
                                default:
                                    completion(.doNotRetryWithError(error))
                            }
                        } else {
                            completion(.doNotRetryWithError(error))
                        }
                    case 429:
                        rateLimitCount = min(rateLimitCount + 1, maxRateLimitCount)
                        completion(.retryWithDelay(rateLimitCount))
                    default:
                        completion(.doNotRetryWithError(error))
                }
            default:
                completion(.doNotRetryWithError(error))
        }
        
    }
    
    private func cancelRetryRequests() {
        requestsToRetry.forEach { $0(false, 0.0) }
        requestsToRetry.removeAll()
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
        
        guard let token = dataSource?.accessToken?.token
        else {
            throw DataError(type: .authentication, subType: .missingAccessToken)
        }
        
        var urlRequest = request
        
        let bearer = String(format: bearerFormat, token)
        urlRequest.setValue(bearer, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        
        return urlRequest
    }
    
    // MARK: - Token Handling
    
    internal func refreshTokens() {
        guard !refreshing
        else {
            return
        }
        
        refreshing = true
        
        guard let delegate = self.delegate
        else {
            cancelRetryRequests()
            
            return
        }
        
        delegate.accessTokenExpired { _ in
            if success {
                self.requestsToRetry.forEach { $0(true, 0.0) }
                self.requestsToRetry.removeAll()
            } else {
                self.requestsToRetry.forEach { $0(false, 0.0) }
                self.requestsToRetry.removeAll()
            }
            
            self.refreshing = false
        }
    }
    
    private func validToken() -> Bool {
        // Check we have an access token
        guard let accessToken = dataSource?.accessToken
        else {
            return false
        }
        
        // Check if we have an expiry date and pre-emptive refresh time otherwise assume it's still good
        guard let expiryDate = accessToken.expiryDate,
            let refreshTime = dataSource?.preemptiveRefreshTime
        else {
            return true
        }
        
        let adjustedExpiryDate = expiryDate.addingTimeInterval(-refreshTime)
        let nowDate = Date()
        
        guard nowDate.compare(adjustedExpiryDate) == .orderedAscending
        else {
            return false
        }
        
        return true
    }
    
}
