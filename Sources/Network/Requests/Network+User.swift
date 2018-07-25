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
    
//    internal func deleteUser(completion: @escaping NetworkCompletion) {
//        requestQueue.async {
//            let url = URL(string: UserEndpoint.user.path, relativeTo: self.serverURL)!
//            
//            self.sessionManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 204...204).responseJSON(queue: self.responseQueue, options: .allowFragments, completionHandler: { (response: DataResponse<Any>) in
//                self.handleCompletion(response: response, completion: completion)
//            })
//        }
//    }
    
    internal func fetchUser(completion: @escaping (_: APIUserResponse?, _: Error?) -> Void) {
        requestQueue.async {
            let url = URL(string: UserEndpoint.details.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response: DataResponse<Data>) in
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
    }
    
//    internal func loginUser(parameters: [String: Any], completion: @escaping NetworkCompletion) {
//        requestQueue.async {
//            let url = URL(string: UserEndpoint.login.path, relativeTo: self.serverURL)!
//
//            self.sessionManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseJSON(queue: self.responseQueue, options: .allowFragments, completionHandler: { (response: DataResponse<Any>) in
//                self.handleTokens(response: response, completion: completion)
//            })
//        }
//    }
//
//    internal func logoutUser(completion: @escaping NetworkCompletion) {
//        requestQueue.async {
//            let url = URL(string: UserEndpoint.logout.path, relativeTo: self.serverURL)!
//
//            self.sessionManager.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseJSON(queue: self.responseQueue, options: .allowFragments, completionHandler: { (response: DataResponse<Any>) in
//                self.handleCompletion(response: response, completion: completion)
//            })
//        }
//    }
//
//    internal func registerUser(parameters: [String: Any], completion: @escaping NetworkCompletion) {
//        requestQueue.async {
//            let url = URL(string: UserEndpoint.register.path, relativeTo: self.serverURL)!
//
//            self.sessionManager.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 201...201).responseJSON(queue: self.responseQueue, options: .allowFragments, completionHandler: { (response: DataResponse<Any>) in
//                self.handleTokens(response: response, completion: completion)
//            })
//        }
//    }
    
}
