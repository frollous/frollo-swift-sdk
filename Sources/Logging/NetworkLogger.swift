//
//  NetworkLogger.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class NetworkLogger: Logger {
    
    private let network: Network?
    
    init(network: Network?) {
        self.network = network
    }
    
    func writeMessage(_ message: String, level: LogLevel) {
        guard let net = network,
            net.authenticator.refreshToken != nil,
            net.authenticator.accessToken != nil
            else {
                return
        }
        
        let request = APILogRequest(details: nil, message: message, score: level)
        
        net.createLog(request: request) { (result) in }
    }
    
}
