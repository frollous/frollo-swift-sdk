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
                                   loginForm: nil,
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
                                   loginForm: nil,
                                   loginHelpMessage: nil,
                                   loginURLString: nil,
                                   mfaType: nil,
                                   oAuthSite: nil,
                                   smallLogoURLString: "https://example.com/small_logo.png")
    }
    
    static func testDetailsCompleteData() -> APIProviderResponse {
        let encryption = APIProviderResponse.Encryption(encryptionType: .encryptValues,
                                                        alias: "enc_alias",
                                                        pem: "PublicKeyHere")
        
        let field1 = ProviderLoginForm.Field(id: "762", image: nil, isOptional: false, maxLength: 8, name: "AccountNumber", option: nil, prefix: nil, suffix: nil, type: .text, validation: nil, value: nil, valueEditable: true)
        
        let row1 = ProviderLoginForm.Row(field: [field1], fieldRowChoice: "Choice1", form: "0001", hint: "Account Number", id: "4512", label: "Account Number", selected: nil)
        
        let loginForm = ProviderLoginForm(id: "7224",
                                          forgetPasswordURL: "https://example.com/forgot",
                                          formType: .login,
                                          help: "Fill in the form",
                                          mfaInfoText: nil,
                                          mfaTimeout: nil,
                                          mfaInfoTitle: nil,
                                          row: [row1])
        
        return APIProviderResponse(id: 54323,
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
                                   loginForm: loginForm,
                                   loginHelpMessage: "Login Help",
                                   loginURLString: "https://example.com/login",
                                   mfaType: .token,
                                   oAuthSite: false,
                                   smallLogoURLString: "https://example.com/small_logo.png")
    }
    
}
