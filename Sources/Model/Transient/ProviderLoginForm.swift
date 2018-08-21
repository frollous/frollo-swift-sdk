//
//  ProviderLoginForm.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

struct ProviderLoginForm: Codable {
    
    struct Row: Codable {
        
        let field: [Field]
        let fieldRowChoice: String
        let form: String
        let hint: String?
        let id: String
        let label: String
        let selected: Bool?
        
    }
    
    struct Field: Codable {
        
        let id: String
        let image: [Int8]?
        let isOptional: Bool
        let maxLength: Int?
        let name: String
        let option: [Option]?
        let prefix: String?
        let suffix: String?
        let type: FieldType
        let validation: [Validation]?
        let value: String?
        let valueEditable: Bool
        
        public func imageData() -> Data? {
            guard let imageArray = image
                else {
                    return nil
            }
            
            let unsignedArray = imageArray.map {
                UInt8(bitPattern: $0)
            }
            return Data(bytes: unsignedArray)
        }
        
    }
    
    struct Option: Codable {
        
        let displayText: String
        let isSelected: Bool?
        let optionValue: String
        
    }
    
    struct Validation: Codable {
        
        let errorMsg: String
        let regExp: String
        
    }
    
    enum FieldType: String, Codable {
        case checkbox
        case image
        case option
        case password
        case radio
        case text
    }
    
    enum FormType: String, Codable {
        case image
        case login
        case questionAndAnswer
        case token
    }
    
    let id: String?
    let forgetPasswordURL: String?
    let formType: FormType
    let help: String?
    let mfaInfoText: String?
    let mfaTimeout: Int?
    let mfaInfoTitle: String?
    let row: [Row]
    
}
