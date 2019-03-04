//
//  Network+Events.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension APIService {
    
    internal func createEvent(request: APIEventCreateRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: EventsEndpoint.events.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.network.contentRequest(url: url, method: .post, content: request)
            else {
                let dataError = DataError(type: .api, subType: .invalidData)
                
                completion(.failure(dataError))
                return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue, completionHandler: { response in
                self.network.handleEmptyResponse(response: response, completion: completion)
            })
        }
    }
    
}
