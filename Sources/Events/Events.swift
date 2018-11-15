//
//  Events.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public class Events {
    
    private let network: Network
    
    internal init(network: Network) {
        self.network = network
    }
    
    public func triggerEvent(_ eventName: String, after delay: Int64? = nil, completion: FrolloSDKCompletionHandler? = nil) {
        let request = APIEventCreateRequest(delayMinutes: delay ?? 0,
                                            event: eventName)
        
        network.createEvent(request: request) { (response, error) in
            if let responseError = error {
                Log.error(responseError.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
}
