//
//  APIProviderResponse+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 31/7/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension APIProviderResponse {
    
    static func testCompleteData() -> APIProviderResponse {
        let encryption = APIProviderResponse.Encryption(encryptionType: .encryptValues,
                                                        alias: "enc_alias",
                                                        pem: "PublicKeyHere")
        
        return APIProviderResponse(id: 54321,
                                   containerNames: [.bank, .creditCard],
                                   name: "Detailed Test Provider",
                                   popular: true,
                                   status: .supported,
                                   authType: .credentials,
                                   baseURLString: "https://example.com/",
                                   encryption: encryption,
                                   forgotPasswordURLString: "https://example.com/iforgot",
                                   helpMessage: "Help me",
                                   largeLogoURLString: "https://example.com/large_logo.png",
                                   loginHelpMessage: "Login Help",
                                   loginURLString: "https://example.com/login",
                                   mfaType: .token,
                                   oAuthSite: false,
                                   smallLogoURLString: "https://example.com/small_logo.png")
    }
    
    static func testIncompleteData() -> APIProviderResponse {
        return APIProviderResponse(id: 908765,
                                   containerNames: [.investment],
                                   name: "List Test Provider",
                                   popular: true,
                                   status: .supported,
                                   authType: nil,
                                   baseURLString: "https://example.com/",
                                   encryption: nil,
                                   forgotPasswordURLString: nil,
                                   helpMessage: nil,
                                   largeLogoURLString: nil,
                                   loginHelpMessage: nil,
                                   loginURLString: nil,
                                   mfaType: nil,
                                   oAuthSite: nil,
                                   smallLogoURLString: "https://example.com/small_logo.png")
    }
    
}
