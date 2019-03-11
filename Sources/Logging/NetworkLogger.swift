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
        
        let deviceInfo = DeviceInfo.current()
        
        let request = APILogRequest(details: nil,
                                    deviceID: deviceInfo.deviceID,
                                    deviceName: deviceInfo.deviceName,
                                    deviceType: deviceInfo.deviceType,
                                    message: message,
                                    score: level)
        
        network.createLog(request: request) { _ in }
    }
    
}
