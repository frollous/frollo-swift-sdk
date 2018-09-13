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
    
    static func loginFormMaxLengthRow() -> ProviderLoginForm.Row {
        let field = ProviderLoginForm.Field(id: "7224",
                                            image: nil,
                                            isOptional: false,
                                            maxLength: 12,
                                            name: "MEMBER_NO",
                                            option: nil,
                                            prefix: nil,
                                            suffix: nil,
                                            type: .text,
                                            validation: nil,
                                            value: "",
                                            valueEditable: true)
        
        return ProviderLoginForm.Row(field: [field],
                                     fieldRowChoice: "0002",
                                     form: "0001",
                                     hint: nil,
                                     id: "7330",
                                     label: "Member Number",
                                     selected: nil)
    }
    
    static func loginFormMultipleChoiceRows() -> [ProviderLoginForm.Row] {
        return [ProviderLoginForm.loginFormMultipleChoiceRow(choice: "0002 Choice"), ProviderLoginForm.loginFormMultipleChoiceRow(choice: "0002 Choice"), ProviderLoginForm.loginFormMultipleChoiceRow(choice: "0002 Choice")]
    }
    
    static func loginFormMultipleChoiceRow(choice: String) -> ProviderLoginForm.Row {
        let field = ProviderLoginForm.Field(id: "65773",
                                            image: nil,
                                            isOptional: true,
                                            maxLength: 12,
                                            name: "OP_LOGIN1",
                                            option: nil,
                                            prefix: nil,
                                            suffix: nil,
                                            type: .text,
                                            validation: nil,
                                            value: "",
                                            valueEditable: true)
        
        return ProviderLoginForm.Row(field: [field],
                                     fieldRowChoice: choice,
                                     form: "0001",
                                     hint: nil,
                                     id: "151124",
                                     label: "An Option",
                                     selected: nil)
    }
    
    static func loginFormValidationField() -> ProviderLoginForm.Row {
        let field = ProviderLoginForm.Field(id: "65773",
                                            image: nil,
                                            isOptional: true,
                                            maxLength: nil,
                                            name: "PASSWORD",
                                            option: nil,
                                            prefix: nil,
                                            suffix: nil,
                                            type: .text,
                                            validation: [ProviderLoginForm.loginFormRegexValidation()],
                                            value: "",
                                            valueEditable: true)
        
        return ProviderLoginForm.Row(field: [field],
                                     fieldRowChoice: "0001",
                                     form: "0001",
                                     hint: nil,
                                     id: "151124",
                                     label: "PASSWORD",
                                     selected: nil)
    }
    
    static func loginFormRegexValidation() -> ProviderLoginForm.Validation {
        return ProviderLoginForm.Validation(errorMsg: "Please enter a valid Access Code", regExp: "^[0-9]{0,6}$")
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
    
    static func loginFormFilledMissingRequiredField() -> ProviderLoginForm {
        var usernameRow = ProviderLoginForm.loginFormUsernameRow()
        usernameRow.field[0].value = ""
        
        let passwordRow = ProviderLoginForm.loginFormPasswordRow()
        
        return ProviderLoginForm(id: "3410",
                                 forgetPasswordURL: "https://secure.amp.com.au/wps/portal/sec/ForgotUsername/!ut/p/a1/04_Sj9CPykssy0xPLMnMz0vMAfGjzOIDDC1cPUzcDbwNLANcDBxdg009vfz9jQxcTfW99KPSc_KTgEoj9SPxKy3IDnIEAM_vx8Q!/",
                                 formType: .login,
                                 help: nil,
                                 mfaInfoText: nil,
                                 mfaTimeout: nil,
                                 mfaInfoTitle: nil,
                                 row: [usernameRow, passwordRow])
    }
    
    static func loginFormFilledInvalidMultipleChoiceField() -> ProviderLoginForm {
        var usernameRow = ProviderLoginForm.loginFormUsernameRow()
        usernameRow.field[0].value = "abc123"
        
        let multipleChoiceRows = ProviderLoginForm.loginFormMultipleChoiceRows()
        
        return ProviderLoginForm(id: "3410",
                                 forgetPasswordURL: "https://secure.amp.com.au/wps/portal/sec/ForgotUsername/!ut/p/a1/04_Sj9CPykssy0xPLMnMz0vMAfGjzOIDDC1cPUzcDbwNLANcDBxdg009vfz9jQxcTfW99KPSc_KTgEoj9SPxKy3IDnIEAM_vx8Q!/",
                                 formType: .login,
                                 help: nil,
                                 mfaInfoText: nil,
                                 mfaTimeout: nil,
                                 mfaInfoTitle: nil,
                                 row: [usernameRow] + multipleChoiceRows)
    }
    
    static func loginFormFilledMaxLengthExceededField() -> ProviderLoginForm {
        var usernameRow = ProviderLoginForm.loginFormUsernameRow()
        usernameRow.field[0].value = "abc123"
        
        var maxLengthRow = ProviderLoginForm.loginFormMaxLengthRow()
        maxLengthRow.field[0].value = "This string is way too long"
        
        return ProviderLoginForm(id: "3410",
                                 forgetPasswordURL: "https://secure.amp.com.au/wps/portal/sec/ForgotUsername/!ut/p/a1/04_Sj9CPykssy0xPLMnMz0vMAfGjzOIDDC1cPUzcDbwNLANcDBxdg009vfz9jQxcTfW99KPSc_KTgEoj9SPxKy3IDnIEAM_vx8Q!/",
                                 formType: .login,
                                 help: nil,
                                 mfaInfoText: nil,
                                 mfaTimeout: nil,
                                 mfaInfoTitle: nil,
                                 row: [usernameRow, maxLengthRow])
    }
    
    static func loginFormFilledRegexInvalidField() -> ProviderLoginForm {
        var regexField = ProviderLoginForm.loginFormValidationField()
        regexField.field[0].value = "Not an access code"
        
        return ProviderLoginForm(id: "3410",
                                forgetPasswordURL: "https://secure.amp.com.au/wps/portal/sec/ForgotUsername/!ut/p/a1/04_Sj9CPykssy0xPLMnMz0vMAfGjzOIDDC1cPUzcDbwNLANcDBxdg009vfz9jQxcTfW99KPSc_KTgEoj9SPxKy3IDnIEAM_vx8Q!/",
                                formType: .login,
                                help: nil,
                                mfaInfoText: nil,
                                mfaTimeout: nil,
                                mfaInfoTitle: nil,
                                row: [regexField])
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
