//
//  FrolloSDKDelegate.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public protocol FrolloSDKDelegate: class {
    
    func eventTriggered(eventName: String)
    func messageReceived(_ messageID: Int64)
    
}
