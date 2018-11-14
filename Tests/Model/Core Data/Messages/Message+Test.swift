//
//  Message+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension Message: TestableCoreData {
    
    @objc func populateTestData() {
        messageID = Int64.random(in: 1...10000000)
        event = String.randomString(range: 1...30)
        userEventID = Int64.random(in: 1...100000)
        placement = Int64.random(in: 1...100000)
        persists = Bool.random()
        read = Bool.random()
        clicked = Bool.random()
        designType = Design.allCases.randomElement()!
        contentType = ContentType.allCases.randomElement()!
        actionTitle = String.randomString(range: 1...50)
        actionURLString = "frollo://dashboard"
        actionOpenExternal = Bool.random()
        buttonTitle = String.randomString(range: 1...50)
        buttonURLString = "https://example.com"
        buttonOpenExternal = Bool.random()
        typeCreditScore = Bool.random()
        typeFeed = Bool.random()
        typeGoal = Bool.random()
        typeHome = Bool.random()
        typePopup = Bool.random()
        typeSetup = Bool.random()
        typeWelcome = Bool.random()
    }
    
}
