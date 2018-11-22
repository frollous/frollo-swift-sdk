//
//  MessageText+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension MessageText {
    
    override func populateTestData() {
        super.populateTestData()
        
        designType = Message.Design.allCases.randomElement()!
        footer = String.randomString(range: 1...100)
        header = String.randomString(range: 1...100)
        imageURLString = "https://example.com/image.png"
        text = String.randomString(range: 1...100)
    }
    
}
