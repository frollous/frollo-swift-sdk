//
//  Network+Events.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    internal func createEvent(request: APIEventCreateRequest, completion: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: EventsEndpoint.events.path, relativeTo: self.serverURL)!
            
            guard let urlRequest = self.contentRequest(url: url, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(nil, dataError)
                    return
            }
            
            self.sessionManager.request(urlRequest).validate(statusCode: 201...201).responseData(queue: self.responseQueue, completionHandler: { (response) in
                self.handleEmptyResponse(response: response, completion: completion)
            })
        }
    }
    
}
