//
//  Data.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

extension Data {

    private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }
    
    internal func hexEncodedString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
    }
    
}
