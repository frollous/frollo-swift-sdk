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
        static let transactionsUpdated = "T_UPDATED"
    }
    
    internal weak var delegate: FrolloSDKDelegate?
    
    private let service: APIService
    
    internal init(service: APIService) {
        self.service = service
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
        
        service.createEvent(request: request) { result in
            switch result {
                case .failure(let error):
                    Log.error(error.localizedDescription)
                    
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                case .success:
                    DispatchQueue.main.async {
                        completion?(.success)
                    }
            }
        }
    }
    
    /**
     Handle an event internally in case it triggers an actions
     
     - parameters:
        - eventName: Name of the event to be handled. Unrecognised ones will be ignored
        - notification: Payload of the associated notification (optional)
        - completion: Completion handler indicating if the event was handled and any error that may have occurred (optional)
    */
    internal func handleEvent(_ eventName: String, notification: NotificationPayload? = nil, completion: ((_ handled: Bool, _ error: Error?) -> Void)? = nil) {
        defer {
            DispatchQueue.main.async {
                self.delegate?.eventTriggered(eventName: eventName)
            }
        }
        
        switch eventName {
            case EventNames.test:
                Log.info("Test event received")
                
                completion?(true, nil)
                
            case EventNames.transactionsUpdated:
                Log.debug("Transactions updated event received")
                
                if let transactionIDs = notification?.transactionIDs, !transactionIDs.isEmpty {
                    NotificationCenter.default.post(name: Aggregation.refreshTransactionsNotification, object: self, userInfo: [Aggregation.refreshTransactionIDsKey: transactionIDs])
                }
                
                completion?(true, nil)
                
            default:
                // Event not recognised
                completion?(false, nil)
        }
    }
    
}
