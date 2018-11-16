//
//  Events.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 15/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 Events
 
 Manages triggering and handling of events from the host
 */
public class Events {
    
    internal struct EventNames {
        static let test = "TEST_EVENT"
    }
    
    private let network: Network
    
    internal init(network: Network) {
        self.network = network
    }
    
    /**
     Trigger an event to occur on the host
     
     - parameters:
        - eventName: Name of the event to trigger. Unrecognised ones will be ignored by the host
        - delay: Delay in minutes for the host to delay the event (optional)
        - completion: Completion handler with option error if something occurs (optional)
    */
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
    
    /**
     Handle an event internally in case it triggers an actions
     
     - parameters:
        - eventName: Name of the event to be handled. Unrecognised ones will be ignored
        - completion: Completion handler indicating if the event was handled and any error that may have occurred (optional)
    */
    internal func handleEvent(_ eventName: String, completion: ((_ handled: Bool, _ error: Error?) -> Void)? = nil) {
        switch eventName {
            case EventNames.test:
                Log.info("Test event received")
            
                completion?(true, nil)
            default:
                // Event not recognised
                completion?(false, nil)
        }
    }
    
}
