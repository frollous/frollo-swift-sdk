//
//  Data.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 12/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

extension Data {
    
//    func hexEncodedString() -> String {
//        return map { String(format: "%02hhx", $0) }.joined()
//    }

    private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }
    
    public func hexEncodedString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
    }
    
}
