//
//  Network+User.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 17/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    typealias UserRequestCompletion = (_: APIUserResponse?, _: Error?) -> Void
    
    internal func changePassword(request: APIUserChangePasswordRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .put, content: request)
               else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(nil, dataError)
                
                return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func deleteUser(completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchUser(completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func loginUser(request: APIUserLoginRequest, completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            guard request.valid
                else {
                    let error = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, error)
                    return
            }
            
            let url = URL(string: UserEndpoint.login.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }

            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                if let error = self.handleTokens(response: response) {
                    completion(nil, error)
                    return
                }
                
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }

    internal func logoutUser(completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.logout.path, relativeTo: self.serverURL)!

            self.sessionManager.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }

    internal func registerUser(request: APIUserRegisterRequest, completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.register.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }

            self.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue) { (response) in
                if let error = self.handleTokens(response: response) {
                    completion(nil, error)
                    return
                }
                
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func resetPassword(request: APIUserResetPasswordRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.resetPassword.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 202...202).responseData(queue: self.responseQueue) { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func updateUser(request: APIUserUpdateRequest, completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .put, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Response Handling
        
    private func handleUserResponse(response: DataResponse<Data>, completion: UserRequestCompletion) {
        switch response.result {
            case .success(let value):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM"
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                do {
                    let tokenResponse = try decoder.decode(APIUserResponse.self, from: value)
                    
                    completion(tokenResponse, nil)
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .unknown, subType: .unknown)
                    completion(nil, dataError)
                }
            case .failure:
                self.handleFailure(response: response) { (error) in
                    completion(nil, error)
                }
        }
    }
    
}
