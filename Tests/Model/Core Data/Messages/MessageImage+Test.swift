//
//  MessageImage+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension MessageImage {
    
    override func populateTestData() {
        super.populateTestData()
        
        height = Double.random(in: 1...1000)
        width = Double.random(in: 1...1000)
        urlString = "https://example.com/image.png"
    }
    
}
