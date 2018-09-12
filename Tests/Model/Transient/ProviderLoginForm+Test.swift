//
//  ProviderLoginForm+Test.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
@testable import FrolloSDK

extension ProviderLoginForm {
    
    static func loginFormUsernameRow() -> ProviderLoginForm.Row {
        let field = ProviderLoginForm.Field(id: "5092",
                                           image: nil,
                                           isOptional: false,
                                           maxLength: nil,
                                           name: "LOGIN",
                                           option: nil,
                                           prefix: nil,
                                           suffix: nil,
                                           type: .text,
                                           validation: nil,
                                           value: "",
                                           valueEditable: true)
        
        return ProviderLoginForm.Row(field: [field],
                                     fieldRowChoice: "0001",
                                     form: "0001",
                                     hint: nil,
                                     id: "7331",
                                     label: "User ID",
                                     selected: nil)
    }
    
    static func loginFormPasswordRow() -> ProviderLoginForm.Row {
        let field = ProviderLoginForm.Field(id: "5091",
                                            image: nil,
                                            isOptional: false,
                                            maxLength: nil,
                                            name: "PASSWORD",
                                            option: nil,
                                            prefix: nil,
                                            suffix: nil,
                                            type: .password,
                                            validation: nil,
                                            value: "",
                                            valueEditable: true)
        
        return ProviderLoginForm.Row(field: [field],
                                     fieldRowChoice: "0002",
                                     form: "0001",
                                     hint: nil,
                                     id: "7330",
                                     label: "Password",
                                     selected: nil)
    }
    
//    static func testLoginFormData() -> ProviderLoginForm {
//
//
//    }
    
    static func loginFormFilledData() -> ProviderLoginForm {
        var usernameRow = ProviderLoginForm.loginFormUsernameRow()
        usernameRow.field[0].value = "abc123"
        
        var passwordRow = ProviderLoginForm.loginFormPasswordRow()
        passwordRow.field[0].value = "password"
        
        return ProviderLoginForm(id: "3410",
                                 forgetPasswordURL: "https://secure.amp.com.au/wps/portal/sec/ForgotUsername/!ut/p/a1/04_Sj9CPykssy0xPLMnMz0vMAfGjzOIDDC1cPUzcDbwNLANcDBxdg009vfz9jQxcTfW99KPSc_KTgEoj9SPxKy3IDnIEAM_vx8Q!/",
                                 formType: .login,
                                 help: nil,
                                 mfaInfoText: nil,
                                 mfaTimeout: nil,
                                 mfaInfoTitle: nil,
                                 row: [usernameRow, passwordRow])
    }
    
//
//    static func testMFAData() -> ProviderLoginForm {
//
//    }
//
//    static func testCaptchaData() -> ProviderLoginForm {
//
//    }
//
//    static func testMultipleChoiceData() -> ProviderLoginForm {
//
//    }
//
//    static func testOptionsData() -> ProviderLoginForm {
//
//    }
    
}
