//
//  ProviderLoginForm.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public struct ProviderLoginForm: Codable {
    
    struct Row: Codable {
        
        var field: [Field]
        let fieldRowChoice: String
        let form: String
        let hint: String?
        let id: String
        let label: String
        var selected: Bool?
        
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
        var value: String?
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
    var row: [Row]
    
    public mutating func encryptValues(encryptionKey: String, encryptionAlias: String) {
        guard let publicKey = SecKeyCreateWithPEMData(encryptionKey, nil)
            else {
                return
        }
        
        for rowIndex in row.indices {
            for fieldIndex in row[rowIndex].field.indices {
                guard let value = row[rowIndex].field[fieldIndex].value,
                    !value.isEmpty
                    else {
                        continue
                }
                
                let data = value.data(using: .utf8)!
                let blockSize = SecKeyGetBlockSize(publicKey)
                
                var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
                var encryptedDataLength = blockSize
                
                var decryptedDataAsArray = [UInt8](repeating: 0, count: data.count / MemoryLayout<UInt8>.size)
                (data as NSData).getBytes(&decryptedDataAsArray, length: data.count)
                
                SecKeyEncrypt(publicKey, .PKCS1, decryptedDataAsArray, decryptedDataAsArray.count, &encryptedDataBuffer, &encryptedDataLength)
                
                let encryptedData = Data(bytes: UnsafePointer<UInt8>(encryptedDataBuffer), count: encryptedDataLength)
                row[rowIndex].field[fieldIndex].value = String(format: "%@:%@", arguments: [encryptionAlias, encryptedData.hexEncodedString()])
            }
        }
    }
    
    public func validateForm() -> (Bool, Error?) {
        // Validate multiple field choice
        var previousFieldRowChoice: String?
        var previousFieldRowMatched = false
        var previousFieldRowSelected = false
        
        for currentRow in row {
            if currentRow.fieldRowChoice == previousFieldRowChoice {
                previousFieldRowMatched = true
                
                if !previousFieldRowSelected, let selected = currentRow.selected, selected {
                    previousFieldRowSelected = true
                }
            } else {
                if !previousFieldRowSelected && previousFieldRowMatched {
                    // No section was selected, fail validation
                    return (false, LoginFormError(type: .fieldChoiceNotSelected, fieldName: currentRow.label))
                } else {
                    previousFieldRowSelected = currentRow.selected ?? false
                }
            }
            
            previousFieldRowChoice = currentRow.fieldRowChoice
        }
        
        // Check final row
        if !previousFieldRowSelected && previousFieldRowMatched {
            // No section was selected, fail validation
            return (false, LoginFormError(type: .fieldChoiceNotSelected, fieldName: row.last!.label))
        }
        
        for currentRow in row {
            for currentField in currentRow.field {
                if !currentField.isOptional && (currentField.value == nil || currentField.value?.isEmpty == true) {
                    // Required field not filled
                    return (false,LoginFormError(type: .missingRequiredField, fieldName: currentField.name))
                } else if let value = currentField.value, let maxLength = currentField.maxLength, value.count > maxLength {
                    // Value is too long
                    return (false, LoginFormError(type: .maxLengthExceeded, fieldName: currentField.name))
                } else if let value = currentField.value, let validation = currentField.validation {
                    for currentValidation in validation {
                        do {
                            let regex = try NSRegularExpression(pattern: currentValidation.regExp, options: [])
                            if regex.numberOfMatches(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count)) < 1 {
                                let error = LoginFormError(type: .validationFailed, fieldName: currentField.name)
                                error.additionalError = currentValidation.errorMsg
                                return (false, error)
                            }
                        } catch {
                            Log.error(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        return (true, nil)
    }
    
}
