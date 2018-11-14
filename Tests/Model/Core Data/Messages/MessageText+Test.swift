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
        
        body = String.randomString(range: 1...100)
    }
    
}
