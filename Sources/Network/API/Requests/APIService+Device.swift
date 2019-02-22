//
//  Network+Device.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 17/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension APIService {
    
    internal func createLog(request: APILogRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: DeviceEndpoint.log.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(.failure(dataError))
                    return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue) { (response) in
                self.network.handleEmptyResponse(response: response, completion: completion)
            }
        }
    }
    
    internal func updateDevice(request: APIDeviceUpdateRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: DeviceEndpoint.device.path, relativeTo: self.serverURL)!
            
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
    
}
