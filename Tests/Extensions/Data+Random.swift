//
//  Data+Random.swift
//  FrolloSDKTests
//
//  Created by Nick Dawson on 3/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

extension Data {
    
    static public func randomData(length: Int) -> Data {
        let bytes = [UInt32](repeating: 0, count: length).map { _ in arc4random() }
        return Data(bytes: bytes, count: length)
    }
    
}
