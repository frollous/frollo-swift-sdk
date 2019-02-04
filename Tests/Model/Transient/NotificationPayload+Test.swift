//
//  File.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 19/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
                                   userMessageID: nil)
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
                                   userMessageID: 98765)
    }
    
    static func testTransactionUpdatedData() -> NotificationPayload {
        return NotificationPayload(aps: nil,
                                   event: "T_UPDATED",
                                   link: nil,
                                   transactionIDs: [45123, 986, 7000072],
                                   userEventID: Int64.random(in: 1...100000000),
                                   userMessageID: nil)
    }
    
}
