//
//  Network+User.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 17/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension APIService {
    
    typealias UserRequestCompletion = (_: Result<APIUserResponse, Error>) -> Void
    
    internal func changePassword(request: APIUserChangePasswordRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
               else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.network.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func deleteUser(completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.network.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func fetchUser(completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }

    internal func logoutUser(completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.logout.path, relativeTo: self.serverURL)!

            self.network.sessionManager.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseData(queue: self.responseQueue) { (response) in
                self.network.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }

    internal func registerUser(request: APIUserRegisterRequest, completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.register.path, relativeTo: self.serverURL)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request, dateEncodingStrategy: .formatted(dateFormatter))
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(.failure(dataError))
                    return
            }

            self.network.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue) { (response) in
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func resetPassword(request: APIUserResetPasswordRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.resetPassword.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(.failure(dataError))
                    return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 202...202).responseData(queue: self.responseQueue) { (response) in
                self.network.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func updateUser(request: APIUserUpdateRequest, completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request, dateEncodingStrategy: .formatted(dateFormatter))
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(.failure(dataError))
                    return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
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
                    
                    completion(.success(tokenResponse))
                } catch {
                    Log.error(error.localizedDescription)
                    
                    let dataError = DataError(type: .api, subType: .invalidData)
                    dataError.systemError = error
                    completion(.failure(dataError))
                }
            case .failure(let error):
                self.network.handleFailure(response: response, error: error) { (processedError) in
                    completion(.failure(processedError))
                }
        }
    }
    
}
