//
//  Network+Messages.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    internal func fetchMessages(completion: @escaping RequestCompletion<[APIMessageResponse]>) {
        requestQueue.async {
            let url = URL(string: MessagesEndpoint.messages.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIMessageResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func fetchUnreadMessages(completion: @escaping RequestCompletion<[APIMessageResponse]>) {
        requestQueue.async {
            let url = URL(string: MessagesEndpoint.unread.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleArrayResponse(type: APIMessageResponse.self, response: response, completion: completion)
            }
        }
        
    }
    
    internal func fetchMessage(messageID: Int64, completion: @escaping RequestCompletion<APIMessageResponse>) {
        requestQueue.async {
            let url = URL(string: MessagesEndpoint.message(messageID: messageID).path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIMessageResponse.self, response: response, completion: completion)
            }
        }
    }
    
    internal func updateMessage(messageID: Int64, request: APIMessageUpdateRequest, completion: @escaping RequestCompletion<APIMessageResponse>) {
        requestQueue.async {
            let url = URL(string: MessagesEndpoint.message(messageID: messageID).path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .put, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
        
            self.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.handleResponse(type: APIMessageResponse.self, response: response, completion: completion)
            }
        }
    }
    
}
