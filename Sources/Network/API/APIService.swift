//
//  APIService.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 21/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

class APIService {
    
    internal let network: Network
    internal let serverURL: URL
    
    /// Asynchronous queue all network requests are executed from
    internal let requestQueue = DispatchQueue(label: "FrolloSDK.APIRequestQueue", qos: .userInitiated, attributes: .concurrent)
    
    /// Asynchornous queue all network responses are executed on
    internal let responseQueue = DispatchQueue(label: "FrolloSDK.APIResponseQueue", qos: .userInitiated, attributes: .concurrent)
    
    init(serverEndpoint: URL, network: Network) {
        self.network = network
        self.serverURL = serverEndpoint
    }
    
}
