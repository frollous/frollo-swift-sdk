//
//  NetworkLogger.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 4/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class NetworkLogger: Logger {
    
    private let service: APIService?
    
    init(service: APIService?) {
        self.service = service
    }
    
    func writeMessage(_ message: String, level: LogLevel) {
        guard let network = service,
            network.network.authenticator.refreshToken != nil,
            network.network.authenticator.accessToken != nil
            else {
                return
        }
        
        let request = APILogRequest(details: nil, message: message, score: level)
        
        network.createLog(request: request) { (result) in }
    }
    
}
