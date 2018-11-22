//
//  MessageHTML+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension MessageHTML {
    
    override func populateTestData() {
        super.populateTestData()
        
        footer = String.randomString(range: 1...20)
        header = String.randomString(range: 1...20)
        main = "<html></html>"
    }
    
}
