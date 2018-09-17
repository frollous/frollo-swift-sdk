//
//  SecKeyPEMTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 30/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest

@testable import FrolloSDK

class SecKeyPEMTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func getDERSecKey() -> SecKey {
        let url = Bundle(for: SecKeyPEMTests.self).url(forResource: "provider-public-key", withExtension: "der")!
        
        let keyData = try! Data(contentsOf: url)
        
        let keyDict: [NSString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: 256)
        ]
        
        return SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, nil)!
    }

    func testPEMToSecKey() {
        let pemKey = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1eXKHvPBlS4A41OvQqFn0SfNH7OgEs2MXMLeyp3xKorEipEKuzv/JDtHFHRAfYwyeiC0q+me0R8GLA6NEDGDfpxGv/XUFyza609ZqtCTOiGCp8DcjLG0mPljdGA1Df0BKhF3y5uata1y0dKSI8aY8lXPza+Tsw4TtjdmHbJ2rR3sFZkYch1RTmNKxKDxMgUmtIk785lIfLJ2x6lvh4ZS9QhuAnsoVM91WWKHrLHYfAeA/zD1TxHDm5/4wPbmFLEBe2+5zGae19nsA/9zDwKP4whpte9HuDDQa5Vsq+aWj5pDJuvFgwA/DStqcHGijn5gzB/JXEoE9qx+dcG92PpvfwIDAQAB\n------END PUBLIC KEY------"
        
        var keyError: Unmanaged<CFError>?
        
        let derKey = SecKeyCreateWithPEMData(pemKey, &keyError)
        
        XCTAssertNil(keyError)
        
        let referenceKey = getDERSecKey()
        
        XCTAssertEqual(referenceKey, derKey)
    }
    
    func testInvalidPEMToSecKey() {
        let pemKey = "ThisisNotaKeygnasogndafgndfjgndfjngdfks"
        
        var keyError: Unmanaged<CFError>?
        
        let derKey = SecKeyCreateWithPEMData(pemKey, &keyError)
        
        XCTAssertNil(derKey)
    }
    
}
