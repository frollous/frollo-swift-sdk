//
//  FrolloSDKDelegate.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 FrolloSDK Delegate
 
 Provides optional callbacks to the host application for real time occurrences such as receiving events or messages
 */
public protocol FrolloSDKDelegate: class {
    
    /**
     Event Triggered
     
     A push notification or other event has been triggered.
     
     - parameters:
        - eventName: Name of the event triggered
    */
    func eventTriggered(eventName: String)
    
    /**
     Message Received
     
     A message was received via push notification. Triggered once the SDK has cached the message contents if not already cached.
     
     - parameters:
        - messageID: Unique identifier of the message received
    */
    func messageReceived(_ messageID: Int64)
    
}
