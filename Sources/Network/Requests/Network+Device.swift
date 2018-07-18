//
//  Network+Device.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 17/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import Alamofire

extension Network {
    
    internal func refreshToken(completionHandler: @escaping NetworkCompletion) {
        requestQueue.async {
            let url = URL(string: DeviceEndpoint.refreshToken.path, relativeTo: self.serverURL)!
            
            self.sessionManager.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200...200).responseJSON(queue: self.responseQueue, options: .allowFragments) { (response: DataResponse<Any>) in
                self.handleTokens(response: response, completion: completionHandler)
            }
        }
    }
    
}
