//
//  ProviderLoginFormTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import XCTest
@testable import FrolloSDK

class ProviderLoginFormTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func jsonResourceNamed(_ fileName: String) -> Data {
        let path = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: path)
    }
    
    func testParsingLoginForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_login")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertEqual(loginForm.id, "13039")
            XCTAssertEqual(loginForm.formType, .login)
            XCTAssertEqual(loginForm.forgetPasswordURL, "https://ib.mebank.com.au/auth/ib/login.html")
            XCTAssertNil(loginForm.help)
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertNil(loginForm.mfaTimeout)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 2)
            
            XCTAssertEqual(loginForm.row[0].label, "Customer ID")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "53364")
            XCTAssertEqual(loginForm.row[0].field[0].name, "LOGIN")
            XCTAssertEqual(loginForm.row[0].field[0].maxLength, 8)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[0].field[0].image)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            XCTAssertNil(loginForm.row[0].field[0].validation)
            
            XCTAssertEqual(loginForm.row[1].label, "Access Code")
            XCTAssertEqual(loginForm.row[1].form, "0001")
            XCTAssertEqual(loginForm.row[1].fieldRowChoice, "0002")
            XCTAssertNil(loginForm.row[1].hint)
            XCTAssertNil(loginForm.row[1].selected)
            
            XCTAssertEqual(loginForm.row[1].field.count, 1)
            
            XCTAssertEqual(loginForm.row[1].field[0].id, "53363")
            XCTAssertEqual(loginForm.row[1].field[0].name, "PASSWORD")
            XCTAssertEqual(loginForm.row[1].field[0].maxLength, 255)
            XCTAssertEqual(loginForm.row[1].field[0].type, .password)
            XCTAssertEqual(loginForm.row[1].field[0].value, "")
            XCTAssertEqual(loginForm.row[1].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[1].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[1].field[0].image)
            XCTAssertNil(loginForm.row[1].field[0].prefix)
            XCTAssertNil(loginForm.row[1].field[0].option)
            XCTAssertNil(loginForm.row[1].field[0].suffix)
            XCTAssertNil(loginForm.row[1].field[0].validation)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParsingCaptchaForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_captcha")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertNil(loginForm.id)
            XCTAssertEqual(loginForm.formType, .image)
            XCTAssertNil(loginForm.forgetPasswordURL)
            XCTAssertNil(loginForm.help)
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertEqual(loginForm.mfaTimeout, 98580)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 1)
            
            XCTAssertEqual(loginForm.row[0].id, "image_row")
            XCTAssertEqual(loginForm.row[0].label, "Enter the words as shown in the image")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            let imageData = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "captcha", withExtension: "bmp")!)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "image")
            XCTAssertEqual(loginForm.row[0].field[0].name, "imageValue")
            XCTAssertEqual(loginForm.row[0].field[0].maxLength, 10)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertEqual(loginForm.row[0].field[0].imageData(), imageData)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            XCTAssertNil(loginForm.row[0].field[0].validation)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParsingMultipleChoiceForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_multiple_choice")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertEqual(loginForm.id, "3326")
            XCTAssertEqual(loginForm.formType, .login)
            XCTAssertEqual(loginForm.forgetPasswordURL, "https://ibank.barclays.co.uk/fp/1_2m/online/1,17266,loginForgottenDetails,00.html?forgottenLoginDetails=true")
            XCTAssertEqual(loginForm.help, "To link your Barclay account you must enter your Surname and one of the following: your Membership Number, Card Number, or Sort Code and Account Number.")
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertNil(loginForm.mfaTimeout)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 4)
            
            XCTAssertEqual(loginForm.row[0].id, "7223")
            XCTAssertEqual(loginForm.row[0].label, "Surname")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "4956")
            XCTAssertEqual(loginForm.row[0].field[0].name, "LOGIN")
            XCTAssertNil(loginForm.row[0].field[0].maxLength)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[0].field[0].image)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            XCTAssertNil(loginForm.row[0].field[0].validation)
            
            XCTAssertEqual(loginForm.row[1].id, "7224")
            XCTAssertEqual(loginForm.row[1].label, "Membership number")
            XCTAssertEqual(loginForm.row[1].form, "0001")
            XCTAssertEqual(loginForm.row[1].fieldRowChoice, "0002 Choice")
            XCTAssertNil(loginForm.row[1].hint)
            XCTAssertNil(loginForm.row[1].selected)
            
            XCTAssertEqual(loginForm.row[1].field.count, 1)
            
            XCTAssertEqual(loginForm.row[1].field[0].id, "4958")
            XCTAssertEqual(loginForm.row[1].field[0].name, "OP_LOGIN1")
            XCTAssertEqual(loginForm.row[1].field[0].maxLength, 12)
            XCTAssertEqual(loginForm.row[1].field[0].type, .text)
            XCTAssertEqual(loginForm.row[1].field[0].value, "")
            XCTAssertEqual(loginForm.row[1].field[0].isOptional, true)
            XCTAssertEqual(loginForm.row[1].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[1].field[0].image)
            XCTAssertNil(loginForm.row[1].field[0].prefix)
            XCTAssertNil(loginForm.row[1].field[0].option)
            XCTAssertNil(loginForm.row[1].field[0].suffix)
            XCTAssertNil(loginForm.row[1].field[0].validation)
            
            XCTAssertEqual(loginForm.row[2].id, "151124")
            XCTAssertEqual(loginForm.row[2].label, "Card number")
            XCTAssertEqual(loginForm.row[2].form, "0001")
            XCTAssertEqual(loginForm.row[2].fieldRowChoice, "0002 Choice")
            XCTAssertNil(loginForm.row[2].hint)
            XCTAssertNil(loginForm.row[2].selected)
            
            XCTAssertEqual(loginForm.row[2].field.count, 1)
            
            XCTAssertEqual(loginForm.row[2].field[0].id, "65773")
            XCTAssertEqual(loginForm.row[2].field[0].name, "OP_LOGIN2")
            XCTAssertEqual(loginForm.row[2].field[0].maxLength, 16)
            XCTAssertEqual(loginForm.row[2].field[0].type, .text)
            XCTAssertEqual(loginForm.row[2].field[0].value, "")
            XCTAssertEqual(loginForm.row[2].field[0].isOptional, true)
            XCTAssertEqual(loginForm.row[2].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[2].field[0].image)
            XCTAssertNil(loginForm.row[2].field[0].prefix)
            XCTAssertNil(loginForm.row[2].field[0].option)
            XCTAssertNil(loginForm.row[2].field[0].suffix)
            XCTAssertNil(loginForm.row[2].field[0].validation)
            
            XCTAssertEqual(loginForm.row[3].id, "151125")
            XCTAssertEqual(loginForm.row[3].label, "Sort code and Account number")
            XCTAssertEqual(loginForm.row[3].form, "0001")
            XCTAssertEqual(loginForm.row[3].fieldRowChoice, "0002 Choice")
            XCTAssertNil(loginForm.row[3].hint)
            XCTAssertNil(loginForm.row[3].selected)
            
            XCTAssertEqual(loginForm.row[3].field.count, 2)
            
            XCTAssertEqual(loginForm.row[3].field[0].id, "65774")
            XCTAssertEqual(loginForm.row[3].field[0].name, "OP_LOGIN3")
            XCTAssertEqual(loginForm.row[3].field[0].maxLength, 6)
            XCTAssertEqual(loginForm.row[3].field[0].type, .text)
            XCTAssertEqual(loginForm.row[3].field[0].value, "")
            XCTAssertEqual(loginForm.row[3].field[0].isOptional, true)
            XCTAssertEqual(loginForm.row[3].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[3].field[0].image)
            XCTAssertNil(loginForm.row[3].field[0].prefix)
            XCTAssertNil(loginForm.row[3].field[0].option)
            XCTAssertNil(loginForm.row[3].field[0].suffix)
            XCTAssertNil(loginForm.row[3].field[0].validation)
            
            XCTAssertEqual(loginForm.row[3].field[1].id, "65764")
            XCTAssertEqual(loginForm.row[3].field[1].name, "OP_LOGIN4")
            XCTAssertEqual(loginForm.row[3].field[1].maxLength, 8)
            XCTAssertEqual(loginForm.row[3].field[1].type, .text)
            XCTAssertEqual(loginForm.row[3].field[1].value, "")
            XCTAssertEqual(loginForm.row[3].field[1].isOptional, true)
            XCTAssertEqual(loginForm.row[3].field[1].valueEditable, true)
            XCTAssertNil(loginForm.row[3].field[1].image)
            XCTAssertNil(loginForm.row[3].field[1].prefix)
            XCTAssertNil(loginForm.row[3].field[1].option)
            XCTAssertNil(loginForm.row[3].field[1].suffix)
            XCTAssertNil(loginForm.row[3].field[1].validation)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParsingQuestionAnswerForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_question_answer")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertNil(loginForm.id)
            XCTAssertEqual(loginForm.formType, .questionAndAnswer)
            XCTAssertNil(loginForm.forgetPasswordURL)
            XCTAssertNil(loginForm.help)
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertEqual(loginForm.mfaTimeout, 99670)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 2)
            
            XCTAssertEqual(loginForm.row[0].id, "SQandA--QUESTION_1--Row--1")
            XCTAssertEqual(loginForm.row[0].label, "What is the name of your state?")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "SQandA--QUESTION_1--1")
            XCTAssertEqual(loginForm.row[0].field[0].name, "QUESTION_1")
            XCTAssertNil(loginForm.row[0].field[0].maxLength)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[0].field[0].image)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            XCTAssertNil(loginForm.row[0].field[0].validation)
            
            XCTAssertEqual(loginForm.row[1].id, "SQandA--QUESTION_2--Row--2")
            XCTAssertEqual(loginForm.row[1].label, "What is the name of your first school")
            XCTAssertEqual(loginForm.row[1].form, "0001")
            XCTAssertEqual(loginForm.row[1].fieldRowChoice, "0002")
            XCTAssertNil(loginForm.row[1].hint)
            XCTAssertNil(loginForm.row[1].selected)
            
            XCTAssertEqual(loginForm.row[1].field.count, 1)
            
            XCTAssertEqual(loginForm.row[1].field[0].id, "SQandA--QUESTION_2--2")
            XCTAssertEqual(loginForm.row[1].field[0].name, "QUESTION_2")
            XCTAssertNil(loginForm.row[1].field[0].maxLength)
            XCTAssertEqual(loginForm.row[1].field[0].type, .password)
            XCTAssertEqual(loginForm.row[1].field[0].value, "")
            XCTAssertEqual(loginForm.row[1].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[1].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[1].field[0].image)
            XCTAssertNil(loginForm.row[1].field[0].prefix)
            XCTAssertNil(loginForm.row[1].field[0].option)
            XCTAssertNil(loginForm.row[1].field[0].suffix)
            XCTAssertNil(loginForm.row[1].field[0].validation)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParsingTokenForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_token")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertNil(loginForm.id)
            XCTAssertEqual(loginForm.formType, .token)
            XCTAssertNil(loginForm.forgetPasswordURL)
            XCTAssertNil(loginForm.help)
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertEqual(loginForm.mfaTimeout, 99180)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 1)
            
            XCTAssertEqual(loginForm.row[0].id, "token_row")
            XCTAssertEqual(loginForm.row[0].label, "Security Key")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "token")
            XCTAssertEqual(loginForm.row[0].field[0].name, "tokenValue")
            XCTAssertEqual(loginForm.row[0].field[0].maxLength, 6)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[0].field[0].image)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            XCTAssertNil(loginForm.row[0].field[0].validation)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParsingOptionsForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_options")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertEqual(loginForm.id, "12525")
            XCTAssertEqual(loginForm.formType, .login)
            XCTAssertNil(loginForm.forgetPasswordURL)
            XCTAssertNil(loginForm.help)
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertNil(loginForm.mfaTimeout)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 4)
            
            XCTAssertEqual(loginForm.row[0].label, "User ID")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "49685")
            XCTAssertEqual(loginForm.row[0].field[0].name, "LOGIN")
            XCTAssertNil(loginForm.row[0].field[0].maxLength)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[0].field[0].image)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            XCTAssertNil(loginForm.row[0].field[0].validation)
            
            XCTAssertEqual(loginForm.row[1].id, "83722")
            XCTAssertEqual(loginForm.row[1].label, "Password")
            XCTAssertEqual(loginForm.row[1].form, "0001")
            XCTAssertEqual(loginForm.row[1].fieldRowChoice, "0002")
            XCTAssertNil(loginForm.row[1].hint)
            XCTAssertNil(loginForm.row[1].selected)
            
            XCTAssertEqual(loginForm.row[1].field.count, 1)
            
            XCTAssertEqual(loginForm.row[1].field[0].id, "49684")
            XCTAssertEqual(loginForm.row[1].field[0].name, "PASSWORD")
            XCTAssertNil(loginForm.row[1].field[0].maxLength)
            XCTAssertEqual(loginForm.row[1].field[0].type, .password)
            XCTAssertEqual(loginForm.row[1].field[0].value, "")
            XCTAssertEqual(loginForm.row[1].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[1].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[1].field[0].image)
            XCTAssertNil(loginForm.row[1].field[0].prefix)
            XCTAssertNil(loginForm.row[1].field[0].option)
            XCTAssertNil(loginForm.row[1].field[0].suffix)
            XCTAssertNil(loginForm.row[1].field[0].validation)
            
            XCTAssertEqual(loginForm.row[2].id, "83720")
            XCTAssertEqual(loginForm.row[2].label, "Question 1")
            XCTAssertEqual(loginForm.row[2].form, "0001")
            XCTAssertEqual(loginForm.row[2].fieldRowChoice, "0003")
            XCTAssertNil(loginForm.row[2].hint)
            XCTAssertNil(loginForm.row[2].selected)
            
            XCTAssertEqual(loginForm.row[2].field.count, 1)
            
            XCTAssertEqual(loginForm.row[2].field[0].id, "49686")
            XCTAssertEqual(loginForm.row[2].field[0].name, "OP_OPTIONS1")
            XCTAssertNil(loginForm.row[2].field[0].maxLength)
            XCTAssertEqual(loginForm.row[2].field[0].type, .option)
            XCTAssertEqual(loginForm.row[2].field[0].value, "")
            XCTAssertEqual(loginForm.row[2].field[0].isOptional, true)
            XCTAssertEqual(loginForm.row[2].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[2].field[0].image)
            XCTAssertNil(loginForm.row[2].field[0].prefix)
            XCTAssertNil(loginForm.row[2].field[0].suffix)
            XCTAssertNil(loginForm.row[2].field[0].validation)
            
            XCTAssertEqual(loginForm.row[2].field[0].option?.count, 10)
            
            XCTAssertEqual(loginForm.row[2].field[0].option?[0].displayText, "What is your father's middle name?")
            XCTAssertEqual(loginForm.row[2].field[0].option?[0].optionValue, "your father's middle name")
            
            XCTAssertEqual(loginForm.row[3].id, "83719")
            XCTAssertEqual(loginForm.row[3].label, "Answer 1")
            XCTAssertEqual(loginForm.row[3].form, "0001")
            XCTAssertEqual(loginForm.row[3].fieldRowChoice, "0004")
            XCTAssertNil(loginForm.row[3].hint)
            XCTAssertNil(loginForm.row[3].selected)
            
            XCTAssertEqual(loginForm.row[3].field.count, 1)
            
            XCTAssertEqual(loginForm.row[3].field[0].id, "49687")
            XCTAssertEqual(loginForm.row[3].field[0].name, "OP_LOGIN1")
            XCTAssertNil(loginForm.row[3].field[0].maxLength)
            XCTAssertEqual(loginForm.row[3].field[0].type, .text)
            XCTAssertEqual(loginForm.row[3].field[0].value, "")
            XCTAssertEqual(loginForm.row[3].field[0].isOptional, true)
            XCTAssertEqual(loginForm.row[3].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[3].field[0].image)
            XCTAssertNil(loginForm.row[3].field[0].prefix)
            XCTAssertNil(loginForm.row[3].field[0].option)
            XCTAssertNil(loginForm.row[3].field[0].suffix)
            XCTAssertNil(loginForm.row[3].field[0].validation)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testParsisngValidationForm() {
        let decoder = JSONDecoder()
        
        let json  = jsonResourceNamed("provider_login_form_validation")
        
        do {
            let loginForm = try decoder.decode(ProviderLoginForm.self, from: json)
            
            XCTAssertEqual(loginForm.id, "3008")
            XCTAssertEqual(loginForm.formType, .login)
            XCTAssertEqual(loginForm.forgetPasswordURL, "https://www.ingdirect.com.au/client/index.aspx")
            XCTAssertNil(loginForm.help)
            XCTAssertNil(loginForm.mfaInfoText)
            XCTAssertNil(loginForm.mfaTimeout)
            XCTAssertNil(loginForm.mfaInfoTitle)
            
            XCTAssertEqual(loginForm.row.count, 2)
            
            XCTAssertEqual(loginForm.row[0].id, "6797")
            XCTAssertEqual(loginForm.row[0].label, "Client Number")
            XCTAssertEqual(loginForm.row[0].form, "0001")
            XCTAssertEqual(loginForm.row[0].fieldRowChoice, "0001")
            XCTAssertNil(loginForm.row[0].hint)
            XCTAssertNil(loginForm.row[0].selected)
            
            XCTAssertEqual(loginForm.row[0].field.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].id, "4410")
            XCTAssertEqual(loginForm.row[0].field[0].name, "LOGIN")
            XCTAssertEqual(loginForm.row[0].field[0].maxLength, 8)
            XCTAssertEqual(loginForm.row[0].field[0].type, .text)
            XCTAssertEqual(loginForm.row[0].field[0].value, "")
            XCTAssertEqual(loginForm.row[0].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[0].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[0].field[0].image)
            XCTAssertNil(loginForm.row[0].field[0].prefix)
            XCTAssertNil(loginForm.row[0].field[0].option)
            XCTAssertNil(loginForm.row[0].field[0].suffix)
            
            XCTAssertEqual(loginForm.row[0].field[0].validation?.count, 1)
            
            XCTAssertEqual(loginForm.row[0].field[0].validation?[0].regExp, "^[0-9]{0,8}$")
            XCTAssertEqual(loginForm.row[0].field[0].validation?[0].errorMsg, "Please enter a valid Client Number")
            
            XCTAssertEqual(loginForm.row[1].id, "6796")
            XCTAssertEqual(loginForm.row[1].label, "Access Code")
            XCTAssertEqual(loginForm.row[1].form, "0001")
            XCTAssertEqual(loginForm.row[1].fieldRowChoice, "0002")
            XCTAssertNil(loginForm.row[1].hint)
            XCTAssertNil(loginForm.row[1].selected)
            
            XCTAssertEqual(loginForm.row[1].field.count, 1)
            
            XCTAssertEqual(loginForm.row[1].field[0].id, "4409")
            XCTAssertEqual(loginForm.row[1].field[0].name, "PASSWORD")
            XCTAssertEqual(loginForm.row[1].field[0].maxLength, 6)
            XCTAssertEqual(loginForm.row[1].field[0].type, .password)
            XCTAssertEqual(loginForm.row[1].field[0].value, "")
            XCTAssertEqual(loginForm.row[1].field[0].isOptional, false)
            XCTAssertEqual(loginForm.row[1].field[0].valueEditable, true)
            XCTAssertNil(loginForm.row[1].field[0].image)
            XCTAssertNil(loginForm.row[1].field[0].prefix)
            XCTAssertNil(loginForm.row[1].field[0].option)
            XCTAssertNil(loginForm.row[1].field[0].suffix)
            
            XCTAssertEqual(loginForm.row[1].field[0].validation?.count, 1)
            
            XCTAssertEqual(loginForm.row[1].field[0].validation?[0].regExp, "^[0-9]{0,6}$")
            XCTAssertEqual(loginForm.row[1].field[0].validation?[0].errorMsg, "Please enter a valid Access Code")
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testProviderLoginFormEncryptionByValues() {
        let encryptionAlias = "09282016_1"
        let encryptionKey = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1eXKHvPBlS4A41OvQqFn0SfNH7OgEs2MXMLeyp3xKorEipEKuzv/JDtHFHRAfYwyeiC0q+me0R8GLA6NEDGDfpxGv/XUFyza609ZqtCTOiGCp8DcjLG0mPljdGA1Df0BKhF3y5uata1y0dKSI8aY8lXPza+Tsw4TtjdmHbJ2rR3sFZkYch1RTmNKxKDxMgUmtIk785lIfLJ2x6lvh4ZS9QhuAnsoVM91WWKHrLHYfAeA/zD1TxHDm5/4wPbmFLEBe2+5zGae19nsA/9zDwKP4whpte9HuDDQa5Vsq+aWj5pDJuvFgwA/DStqcHGijn5gzB/JXEoE9qx+dcG92PpvfwIDAQAB\n------END PUBLIC KEY------"
        
        var form = ProviderLoginForm.loginFormFilledData()
        
        form.encryptValues(encryptionKey: encryptionKey, encryptionAlias: encryptionAlias)
        
        XCTAssertTrue(form.row[0].field[0].value!.contains(encryptionAlias))
        XCTAssertEqual(form.row[0].field[0].value?.count, 523)
        XCTAssertTrue(form.row[1].field[0].value!.contains(encryptionAlias))
        XCTAssertEqual(form.row[1].field[0].value?.count, 523)
        XCTAssertNotEqual(form.row[0].field[0].value, form.row[1].field[0].value)
    }
    
    func testProviderLoginFormMultipleChoiceValidation() {
        let loginForm = ProviderLoginForm.loginFormFilledInvalidMultipleChoiceField()
        
        let result = loginForm.validateForm()
        
        XCTAssertFalse(result.0)
        XCTAssertNotNil(result.1)
        
        if let error = result.1 as? LoginFormError {
            XCTAssertEqual(error.type, .fieldChoiceNotSelected)
            XCTAssertEqual(error.fieldName, "An Option")
        }
    }
    
    func testProviderLoginFormOptionalValidation() {
        let loginForm = ProviderLoginForm.loginFormFilledMissingRequiredField()
        
        let result = loginForm.validateForm()
        
        XCTAssertFalse(result.0)
        XCTAssertNotNil(result.1)
        
        if let error = result.1 as? LoginFormError {
            XCTAssertEqual(error.type, .missingRequiredField)
            XCTAssertEqual(error.fieldName, "LOGIN")
        }
    }
    
    func testProviderLoginFormMaxLengthValidation() {
        let loginForm = ProviderLoginForm.loginFormFilledMaxLengthExceededField()
        
        let result = loginForm.validateForm()
        
        XCTAssertFalse(result.0)
        XCTAssertNotNil(result.1)
        
        if let error = result.1 as? LoginFormError {
            XCTAssertEqual(error.type, .maxLengthExceeded)
            XCTAssertEqual(error.fieldName, "MEMBER_NO")
        }
    }
    
    func testProviderLoginFormRegexValidation() {
        let loginForm = ProviderLoginForm.loginFormFilledRegexInvalidField()
        
        let result = loginForm.validateForm()
        
        XCTAssertFalse(result.0)
        XCTAssertNotNil(result.1)
        
        if let error = result.1 as? LoginFormError {
            XCTAssertEqual(error.type, .validationFailed)
            XCTAssertEqual(error.fieldName, "PASSWORD")
            XCTAssertEqual(error.additionalError, "Please enter a valid Access Code")
        }
    }

}
