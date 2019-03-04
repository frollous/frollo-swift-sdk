//
//  SecKeyPEM.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import Security

internal func SecKeyCreateWithPEMData(_ keyData: String, _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey? {
    guard !keyData.isEmpty
    else {
        return nil
    }
    
    do {
        let regex = try NSRegularExpression(pattern: "(-{5})(.*?)(PUBLIC KEY-+)|[\r\n]", options: [])
        
        let matches = regex.matches(in: keyData, options: [], range: NSRange(location: 0, length: keyData.utf16.count))
        
        let strippedPEM = NSMutableString(string: keyData)
        
        for match in matches.reversed() {
            strippedPEM.replaceCharacters(in: match.range, with: "")
        }
        
        guard let derPublicKey = Data(base64Encoded: strippedPEM as String)
        else {
            return nil
        }
        
        let keyDict: [NSString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                        kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                        kSecAttrKeySizeInBits: NSNumber(value: 256)]
        
        return SecKeyCreateWithData(derPublicKey as CFData, keyDict as CFDictionary, nil)
    } catch {
        return nil
    }
}
