//
//  NetworkAuthenticator.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

class NetworkAuthenticator: RequestAdapter, RequestRetrier {
    
    internal struct KeychainKey {
        static let accessToken = "accessToken"
        static let accessTokenExpiry = "accessTokenExpiry"
        static let refreshToken = "refreshToken"
    }
    
    /**
     Access Token used with the API
    */
    internal var accessToken: String?
    
    /**
     Refresh Token used with the API to renew access tokens
    */
    internal var refreshToken: String?
    
    /**
     Expiry date of the access token, typically 30 minutes after issue
    */
    internal var expiryDate: Date?
    
    private let bearerFormat = "Bearer %@"
    private let keychain: Keychain
    private let lock = NSLock()
    private let maxRateLimitCount: Double = 10
    private let timeInterval5Minutes: Double = 300
    
    private var rateLimitCount: Double = 0
    private var refreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    private weak var network: Network?
    
    init(network: Network, keychain: Keychain) {
        self.network = network
        self.keychain = keychain
        
        loadTokens()
    }
    
    internal func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let baseURL = network?.serverURL, let url = urlRequest.url, url.absoluteString.hasPrefix(baseURL.absoluteString)
            else {
                return urlRequest
        }
        
        var request = urlRequest
        
        if let relativePath = request.url?.relativePath {
            if relativePath.contains(UserEndpoint.register.path) || relativePath.contains(UserEndpoint.resetPassword.path) {
                // Use the OTP for authorisation
                return appendOTPHeader(request: request)
            } else if relativePath.contains(DeviceEndpoint.refreshToken.path) {
                do {
                    let adaptedRequest = try appendRefreshToken(request: request)
                    return adaptedRequest
                } catch let error {
                    throw error
                }
            } else if !relativePath.contains(UserEndpoint.login.path) {
                // No auth header for login or reset password
                do {
                    let adaptedRequest = try validateAndAppendAccessToken(request: request)
                    return adaptedRequest
                } catch let error {
                    throw error
                }
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
        
        lock.lock() ; defer { lock.unlock() }
        
        switch responseError {
            case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
                switch code {
                    case 401:
                        if let data = request.delegate.data {
                            let apiError = APIError(statusCode: code, response: data)
                            switch apiError.type {
                                case .invalidAccessToken:
                                    // Refresh the token
                                    requestsToRetry.append(completion)
                                    
                                    refreshTokens()
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
    
    private func appendOTPHeader(request: URLRequest) -> URLRequest {
        var urlRequest = request
        
        let bundleID = String(repeating: Bundle(for: NetworkAuthenticator.self).bundleIdentifier ?? "FrolloSDK", count: 2)

        let generator = OTP(factor: .timer(period: 30), secret: bundleID.data(using: .utf8)!, algorithm: .sha256, digits: 8)
        let password = try! generator?.password(at: Date())
        let bearer = String(format: "Bearer %@", password!)
        urlRequest.setValue(bearer, forHTTPHeaderField: Network.HTTPHeader.authorization.rawValue)
        
        return urlRequest
    }
    
    private func appendRefreshToken(request: URLRequest) throws -> URLRequest {
        guard let token = refreshToken
            else {
                throw DataError(type: .authentication, subType: .missingRefreshToken)
        }
        
        var urlRequest = request
        
        let bearer = String(format: bearerFormat, token)
        urlRequest.setValue(bearer, forHTTPHeaderField: Network.HTTPHeader.authorization.rawValue)
        
        return urlRequest
    }
    
    internal func validateAndAppendAccessToken(request: URLRequest) throws -> URLRequest {
        if !validToken() {
            guard refreshToken != nil
                else {
                    Log.error("No valid refresh token when trying to refresh access token.")

                    throw DataError(type: .authentication, subType: .missingRefreshToken)
            }

            lock.lock()

            let semaphore = DispatchSemaphore(value: 0)

            requestsToRetry.append({ (retry: Bool, delay: TimeInterval) in
                // Unblock once token has updated
                semaphore.signal()
            })

            refreshTokens()

            lock.unlock()

            semaphore.wait()
        }

        guard accessToken != nil
            else {
                throw DataError(type: .authentication, subType: .missingAccessToken)
        }

        var urlRequest = request

        let bearer = String(format: bearerFormat, accessToken!)
        urlRequest.setValue(bearer, forHTTPHeaderField: Network.HTTPHeader.authorization.rawValue)

        return urlRequest
    }
    
    // MARK: - Token Handling
    
    /**
     Cache tokens and save tokens to the keychain
     
     - parameters:
         - refresh: Refresh token
         - access: Access token
         - expiry: Access token expiry date
    */
    internal func saveTokens(refresh: String, access: String, expiry: Date) {
        refreshToken = refresh
        accessToken = access
        expiryDate = expiry
        
        keychain[KeychainKey.accessToken] = access
        keychain[KeychainKey.refreshToken] = refresh
    
        let expirySeconds = String(expiry.timeIntervalSince1970)
        keychain[KeychainKey.accessTokenExpiry] = expirySeconds
    }
    
    /**
     Clear the cached tokens and delete any keychain persisted tokens
    */
    internal func clearTokens() {
        accessToken = nil
        expiryDate = nil
        refreshToken = nil
        
        keychain.removeAll()
    }
    
    internal func refreshTokens() {
        guard !refreshing
            else {
                return
        }
        
        refreshing = true
        
        network?.refreshToken(completion: { (result) in
            switch result {
                case .success:
                    self.requestsToRetry.forEach { $0(false, 0.0) }
                    self.requestsToRetry.removeAll()
                
                case .failure(let error):
                    if let apiError = error as? APIError, apiError.type == .invalidRefreshToken {
                        self.clearTokens()
                        
                        Log.error("Refreshing token failed due to authorisation error." + apiError.localizedDescription)
                    }
                    
                    self.requestsToRetry.forEach { $0(true, 0.0) }
                    self.requestsToRetry.removeAll()
            }
            
            self.refreshing = false
        })
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
        refreshToken = keychain[KeychainKey.refreshToken]
        
        if let expiryTime = keychain[KeychainKey.accessTokenExpiry], let expirySeconds = TimeInterval(expiryTime) {
            expiryDate = Date(timeIntervalSince1970: expirySeconds)
        }
    }
    
}
