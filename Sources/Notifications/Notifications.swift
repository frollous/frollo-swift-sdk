//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/**
 Notifications
 
 Register for push notifications and handles incoming push notification payloads.
 */
public class Notifications {
    
    private let events: Events
    private let messages: Messages
    private let user: UserManagement
    
    internal init(events: Events, messages: Messages, user: UserManagement) {
        self.events = events
        self.messages = messages
        self.user = user
    }
    
    /**
     Register Push Notification Token
     
     Registers the device token received from APNS to the host to allow for push notifications to be sent
     
     - parameters:
        - token: Raw token data received from APNS to be sent to the host
     */
    public func registerPushNotificationToken(_ token: Data) {
        let notificationToken = token.hexEncodedString()
        
        user.updateDevice(notificationToken: notificationToken)
    }
    
    /**
     Handle Push Notification
     
     Handles the userInfo payload on a push notification. Any custom data or message content will be processed by the SDK.
     
     - parameters:
        - userInfo: Notification user info payload received from the push
     */
    public func handlePushNotification(userInfo: [AnyHashable: Any]) {
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
