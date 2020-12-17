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

extension APIService {
    
    internal typealias UserRequestCompletion = (_: Swift.Result<APIUserResponse, Error>) -> Void
    
    internal func changePassword(request: APIUserChangePasswordRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func deleteUser(completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchUser(completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.handleUserResponse(response: response, completion: completion)
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
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
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
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue, emptyResponseCodes: [202]) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateUser(request: APIUserUpdateRequest, otpCode: String?, completion: @escaping UserRequestCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request, dateEncodingStrategy: .formatted(dateFormatter), userOtp: otpCode)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.handleUserResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func migrateUser(request: APIUserMigrationRequest, token: String, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.migrate.path, relativeTo: self.serverURL)!
            
            guard var urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                
                return
            }
            
            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func sendOTP(request: APIUserOTPRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.requestOTP.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchUnconfirmedUserDetails(completion: @escaping RequestCompletion<APIUserDetailsConfirm>) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.unconfirmedDetails.path, relativeTo: self.serverURL)!
            
            self.network.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleResponse(type: APIUserDetailsConfirm.self, errorType: APIError.self, response: response, completion: completion)
            }
            
        }
    }
    
    internal func confirmUserDetails(request: APIUserDetailsConfirm, otpCode: String?, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.confirmDetails.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .put, content: request, userOtp: otpCode)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...299).responseData(queue: self.responseQueue) { response in
                self.network.handleEmptyResponse(errorType: APIError.self, response: response, completion: completion)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleUserResponse(response: DataResponse<Data, AFError>, completion: UserRequestCompletion) {
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
                network.handleFailure(type: APIError.self, response: response, error: error) { processedError in
                    completion(.failure(processedError))
                }
        }
    }
    
}
