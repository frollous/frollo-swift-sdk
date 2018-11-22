//
//  Notifications.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 16/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 Notifications
 
 Register for push notifications and handles incoming push notification payloads.
 */
public class Notifications {
    
    private let authentication: Authentication
    private let events: Events
    private let messages: Messages
    
    internal init(authentication: Authentication, events: Events, messages: Messages) {
        self.authentication = authentication
        self.events = events
        self.messages = messages
    }
    
    /**
     Register Push Notification Token
     
     Registers the device token received from APNS to the host to allow for push notifications to be sent
     
     - parameters:
        - token: Raw token data received from APNS to be sent to the host
    */
    public func registerPushNotificationToken(_ token: Data) {
        let notificationToken = token.hexEncodedString()
        
        authentication.updateDevice(notificationToken: notificationToken)
    }
    
    /**
     Handle Push Notification
     
     Handles the userInfo payload on a push notification. Any custom data or message content will be processed by the SDK.
     
     - parameters:
        - userInfo: Notification user info payload received from the push
    */
    public func handlePushNotification(userInfo: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: [])
            else {
                return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let notificationPayload = try decoder.decode(NotificationPayload.self, from: jsonData)
            
            if let event = notificationPayload.event {
                events.handleEvent(event, notification: notificationPayload)
            }
            if notificationPayload.aps?.alert != nil, notificationPayload.userMessageID != nil {
                messages.handleMessageNotification(notificationPayload)
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
}
