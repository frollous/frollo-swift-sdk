//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
