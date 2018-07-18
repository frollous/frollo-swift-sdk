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
    
    internal var accessToken: String?
    internal var refreshToken: String?
    internal var expiryDate: Date?
    
    private let bearerFormat = "Bearer %@"
    private let lock = NSLock()
    private let maxRateLimitCount: Double = 10
    private let timeInterval5Minutes: Double = 300
    
    private var rateLimitCount: Double = 0
    private var refreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    private weak var network: Network?
    
    init(network: Network) {
        self.network = network
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
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
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
        
        let bundleID = String(repeating: Bundle.main.bundleIdentifier!, count: 2)
        
//        let generator = Generator(factor: .timer(period: 30), secret: bundleID.data(using: .utf8)!, algorithm: .sha256, digits: 8)
//        let password = try! generator?.password(at: Date())
//        let bearer = String(format: "Bearer %@", password!)
//        urlRequest.setValue(bearer, forHTTPHeaderField: APIClient.HTTPHeader.authorization)
        
        return urlRequest
    }
    
    private func appendRefreshToken(request: URLRequest) throws -> URLRequest {
        guard let token = refreshToken
            else {
                throw DataError(type: .authentication, subType: .missingRefreshToken)
        }
        
        var urlRequest = request
        
        let bearer = String(format: bearerFormat, token)
        urlRequest.setValue(bearer, forHTTPHeaderField: Network.HTTPHeader.authorization)
        
        return urlRequest
    }
    
    private func validateAndAppendAccessToken(request: URLRequest) throws -> URLRequest {
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
        urlRequest.setValue(bearer, forHTTPHeaderField: Network.HTTPHeader.authorization)

        return urlRequest
    }
    
    // MARK: - Token Handling
    
    internal func saveTokens(refresh: String, access: String, expiry: Date) {
        refreshToken = refresh
        accessToken = access
        expiryDate = expiry
        
        // TODO: Save to actual keychain
        //keychain[KeychainConstants.refreshTokenKey] = token
        //keychain[KeychainConstants.accessTokenKey] = accessToken
        //UserDefaults.standard.set(expiry, forKey: UserDefaultsConstants.accessTokenExpiryKey)
    }
    
    internal func clearTokens() {
        accessToken = nil
        expiryDate = nil
        refreshToken = nil
        
        // TODO: Save to actual keychain
        //try! keychain.removeAll()
        
        //UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.accessTokenExpiryKey)
    }
    
    private func refreshTokens() {
        guard !refreshing
            else {
                return
        }
        
        refreshing = true
        
        network?.refreshToken(completionHandler: { (json, error) in
            if let responseError = error {
                if let apiError = error as? APIError, apiError.type == .invalidRefreshToken {
                    self.clearTokens()
                    
                    Log.error("Refreshing token failed due to authorisation error." + responseError.localizedDescription)
                }
                
                self.requestsToRetry.forEach { $0(false, 0.0) }
                self.requestsToRetry.removeAll()
            } else {
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
        // TODO: Load from actual keychain
        //accessToken = keychain[KeychainConstants.accessTokenKey]
        //refreshToken = keychain[KeychainConstants.refreshTokenKey]
        //expiryDate = UserDefaults.standard.object(forKey: UserDefaultsConstants.accessTokenExpiryKey) as? Date
    }
    
}
