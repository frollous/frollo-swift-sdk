//
//  Notifications.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 16/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public class Notifications {
    
    private let authentication: Authentication
    private let events: Events
    private let messages: Messages
    
    internal init(authentication: Authentication, events: Events, messages: Messages) {
        self.authentication = authentication
        self.events = events
        self.messages = messages
    }
    
    public func registerPushNotificationToken(_ token: Data) {
        let notificationToken = token.hexEncodedString()
        
        authentication.updateDevice(notificationToken: notificationToken)
    }
    
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
