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

/// Apple Push Notification Payload
public struct NotificationPayload: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case aps
        case event
        case link
        case transactionIDs = "transaction_ids"
        case userEventID = "user_event_id"
        case userMessageID = "user_message_id"
        case onboardingStep = "onboarding_step"
    }
    
    /// Proprietary Apple Push Notification (APNS) Payload
    public struct ApplePayload: Codable {
        
        private enum CodingKeys: String, CodingKey {
            
            case alert
            case badge
            case category
            case contentAvailable = "content-available"
            case mutableContent = "mutable-content"
            case sound
            case threadID = "thread-id"
            
        }
        
        /// APNS Alert content
        public struct Alert: Codable {
            
            private enum CodingKeys: String, CodingKey {
                
                case body
                case launchImage = "launch-image"
                case locArgs = "loc-args"
                case locKey = "loc-key"
                case subtitle
                case subtitleLocArgs = "subtitle-loc-args"
                case subtitleLocKey = "subtitle-loc-key"
                case title
                case titleLocArgs = "title-loc-args"
                case titleLocKey = "title-loc-key"
                
            }
            
            /// The text of the alert message.
            public let body: String?
            
            /// The filename of an image file in the app bundle, with or without the filename extension. The image is used as the launch image when users tap the action button or move the action slider. If this property is not specified, the system either uses the previous snapshot, uses the image identified by the UILaunchImageFile key in the app’s Info.plist file, or falls back to Default.png.
            public let launchImage: String?
            
            /// Variable string values to appear in place of the format specifiers in loc-key. See Localizing the Content of Your Remote Notifications for more information.
            public let locArgs: [String]?
            
            /// A key to an alert-message string in a Localizable.strings file for the current localization (which is set by the user’s language preference). The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the loc-args array. See Localizing the Content of Your Remote Notifications for more information.
            public let locKey: String?
            
            /// Additional information that explains the purpose of the notification.
            public let subtitle: String?
            
            /// An array of strings containing replacement values for variables in your title string. Each %@ character in the string specified by subtitle-loc-key is replaced by a value from this array. The first item in the array replaces the first instance of the %@ character in the string, the second item replaces the second instance, and so on.
            public let subtitleLocArgs: [String]?
            
            /// The key for a localized subtitle string. Use this key, instead of the subtitle key, to retrieve the subtitle from your app's Localizable.strings file. The value must contain the name of a key in your strings file.
            public let subtitleLocKey: String?
            
            /// The title of the notification. Apple Watch displays this string in the short look notification interface. Specify a string that is quickly understood by the user.
            public let title: String?
            
            /// An array of strings containing replacement values for variables in your title string. Each %@ character in the string specified by the title-loc-key is replaced by a value from this array. The first item in the array replaces the first instance of the %@ character in the string, the second item replaces the second instance, and so on.
            public let titleLocArgs: [String]?
            
            /// The key for a localized title string. Specify this key instead of the title key to retrieve the title from your app’s Localizable.strings files. The value must contain the name of a key in your strings file.
            public let titleLocKey: String?
            
        }
        
        /// A dictionary that contains sound information for critical alerts
        public struct Sound: Codable {
            
            /// The critical alert flag. Set to 1 to enable the critical alert.
            public let critical: Int?
            
            /// The name of a sound file in your app’s main bundle or in the Library/Sounds folder of your app’s container directory. Specify the string "default" to play the system sound.
            public let name: String?
            
            /// The volume for the critical alert’s sound. Set this to a value between 0.0 (silent) and 1.0 (full volume).
            public let volume: Double?
            
        }
        
        /// The information for displaying an alert. A dictionary is recommended. If you specify a string, the alert displays your string as the body text.
        public let alert: Alert?
        
        /// The number to display in a badge on your app’s icon. Specify 0 to remove the current badge, if any.
        public let badge: Int?
        
        /// The notification’s type. This string must correspond to the identifier of one of the UNNotificationCategory objects you register at launch time. See Declaring Your Actionable Notification Types.
        public let category: String?
        
        /// The background notification flag. To perform a silent background update, specify the value 1 and don't include the alert, badge, or sound keys in your payload. See Pushing Updates to Your App Silently.
        public let contentAvailable: Int?
        
        /// The notification service app extension flag. If the value is 1, the system passes the notification to your notification service app extension before delivery. Use your extension to modify the notification’s content. See Modifying Content in Newly Delivered Notifications.
        public let mutableContent: Int?
        
        /// A dictionary that contains sound information for critical alerts
        public let sound: Sound?
        
        /// An app-specific identifier for grouping related notifications. This value corresponds to the threadIdentifier property in the UNNotificationContent object.
        public let threadID: String?
        
    }
    
    /// Apple proprietary push notification payload
    public let aps: ApplePayload?
    
    /// Name of the event associated with the notification
    public let event: String?
    
    /// Deep link to take the user to
    public let link: String?
    
    /// A list of transaction IDs that have been updated on the host and should be refreshed
    public let transactionIDs: [Int64]?
    
    /// The unique ID of the event for that user
    public let userEventID: Int64?
    
    /// The unique ID of the message associated with this notification
    public let userMessageID: Int64?
    
    /// The name of onboarding event
    public let onboardingStep: String?
    
}
