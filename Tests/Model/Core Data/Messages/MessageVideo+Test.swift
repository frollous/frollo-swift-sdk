//
//  MessageVideo+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 14/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import Foundation
@testable import FrolloSDK

extension MessageVideo {
    
    override func populateTestData() {
        super.populateTestData()
        
        height = Double.random(in: 1...1000)
        width = Double.random(in: 1...1000)
        autoplay = Bool.random()
        autoplayCellular = Bool.random()
        muted = Bool.random()
        iconURLString = "https://example.com/thumbnail.png"
        urlString = "https://example.com/video.mp4"
    }
    
}
