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
@testable import FrolloSDK

extension NotificationPayload {
    
    static func testEventData() -> NotificationPayload {
        return NotificationPayload(aps: nil,
                                   event: "TEST_EVENT",
                                   link: nil,
                                   transactionIDs: nil,
                                   userEventID: 12345,
                                   userMessageID: nil,
                                   onboardingStep: nil)
    }
    
    static func testMessageData() -> NotificationPayload {
        let alert = NotificationPayload.ApplePayload.Alert(body: String.randomString(range: 1...50),
                                                           launchImage: "ImageFile.png",
                                                           locArgs: ["arg1", "arg2"],
                                                           locKey: "key1",
                                                           subtitle: String.randomString(range: 1...50),
                                                           subtitleLocArgs: ["arg1", "arg2", "arg3", "arg4"],
                                                           subtitleLocKey: "key2",
                                                           title: String.randomString(range: 1...20),
                                                           titleLocArgs: ["arg1"],
                                                           titleLocKey: "key3")
        let sound = NotificationPayload.ApplePayload.Sound(critical: 1,
                                                           name: "soundfile.aiff",
                                                           volume: 1.0)
        
        let aps = NotificationPayload.ApplePayload(alert: alert,
                                                   badge: 137,
                                                   category: "NOTI_CAT_1",
                                                   contentAvailable: 1,
                                                   mutableContent: 1,
                                                   sound: sound,
                                                   threadID: "THREAD1")
        
        return NotificationPayload(aps: aps,
                                   event: "TEST_MESSAGE",
                                   link: "frollo://dashboard",
                                   transactionIDs: nil,
                                   userEventID: 12345,
                                   userMessageID: 98765,
                                   onboardingStep: "account_opening")
    }
    
    static func testTransactionUpdatedData() -> NotificationPayload {
        return NotificationPayload(aps: nil,
                                   event: "T_UPDATED",
                                   link: nil,
                                   transactionIDs: [45123, 986, 7000072],
                                   userEventID: Int64.random(in: 1...100000000),
                                   userMessageID: nil,
                                   onboardingStep: nil)
    }
    
    static func testOnboardingData() -> NotificationPayload {
        return NotificationPayload(aps: nil,
                                   event: "ONBOARDING_STEP_COMPLETED",
                                   link: nil,
                                   transactionIDs: nil,
                                   userEventID: nil,
                                   userMessageID: nil,
                                   onboardingStep: "account_opening")
    }
    
}
