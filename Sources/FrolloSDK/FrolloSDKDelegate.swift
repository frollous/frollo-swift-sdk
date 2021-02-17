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
 FrolloSDK Delegate
 
 Provides optional callbacks to the host application for real time occurrences such as receiving events or messages
 */
public protocol FrolloSDKDelegate: AnyObject {
    
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
