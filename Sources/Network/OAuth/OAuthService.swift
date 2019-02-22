//
//  OAuthService.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

class OAuthService {
    
    internal let network: Network
    internal let tokenURL: URL
    
    /// Asynchronous queue all network requests are executed from
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    
    /// Asynchornous queue all network responses are executed on
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    
    init(tokenEndpoint: URL, network: Network) {
        self.network = network
        self.tokenURL = tokenEndpoint
    }
    
    internal func refreshTokens(request: OAuthTokenRequest, completion: @escaping RequestCompletion<OAuthTokenResponse>) {
        requestQueue.async {
            guard request.valid
                else {
                    let error = DataError(type: .api, subType: .invalidData)
                    
                    completion(.failure(error))
                    return
            }
            
            guard let urlRequest = self.network.contentRequest(url: self.tokenURL, method: .post, content: request)
                else {
                    let dataError = DataError(type: .api, subType: .invalidData)
                    
                    completion(.failure(dataError))
                    return
            }
            
            self.network.sessionManager.request(urlRequest).validate(statusCode: 200...200).responseData(queue: self.responseQueue) { (response) in
                self.network.handleResponse(type: OAuthTokenResponse.self, response: response, dateDecodingStrategy: .secondsSince1970, completion: completion)
            }
        }
    }
    
}
