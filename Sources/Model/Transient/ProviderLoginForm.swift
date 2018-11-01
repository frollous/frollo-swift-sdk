//
//  ProviderLoginForm.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 20/8/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import Security

public struct ProviderLoginForm: Codable {
    
    public struct Row: Codable {
        
        public var field: [Field]
        public let fieldRowChoice: String
        public let form: String
        public let hint: String?
        public let id: String
        public let label: String
        
    }
    
    public struct Field: Codable {
        
        public let id: String
        public let image: [Int8]?
        public let isOptional: Bool
        public let maxLength: Int?
        public let name: String
        public let option: [Option]?
        public let prefix: String?
        public let suffix: String?
        public let type: FieldType
        public let validation: [Validation]?
        public var value: String?
        public let valueEditable: Bool
        
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
    
    public struct Option: Codable {
        
        public let displayText: String
        public let isSelected: Bool?
        public let optionValue: String
        
    }
    
    public struct Validation: Codable {
        
        public let errorMsg: String
        public let regExp: String
        
    }
    
    public enum FieldType: String, Codable {
        case checkbox
        case image
        case option
        case password
        case radio
        case text
    }
    
    public enum FormType: String, Codable {
        case image
        case login
        case questionAndAnswer
        case token
    }
    
    public let id: String?
    public let forgetPasswordURL: String?
    public let formType: FormType
    public let help: String?
    public let mfaInfoText: String?
    public let mfaTimeout: Int?
    public let mfaInfoTitle: String?
    public var row: [Row]
    
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
                
                var encryptedData: Data?
                
                #if os(macOS)
                var error: Unmanaged<CFError>?
                
                let transform = SecEncryptTransformCreate(publicKey, &error)
                guard error == nil
                    else {
                        continue
                }
                
                guard SecTransformSetAttribute(transform, kSecTransformInputAttributeName, data as CFData, &error)
                    else {
                        continue
                }
                
                encryptedData = SecTransformExecute(transform, &error) as? Data
                guard error == nil
                    else {
                        continue
                }
                #else
                let blockSize = SecKeyGetBlockSize(publicKey)
                
                var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
                var encryptedDataLength = blockSize
                
                var decryptedDataAsArray = [UInt8](repeating: 0, count: data.count / MemoryLayout<UInt8>.size)
                (data as NSData).getBytes(&decryptedDataAsArray, length: data.count)
                
                SecKeyEncrypt(publicKey, .PKCS1, decryptedDataAsArray, decryptedDataAsArray.count, &encryptedDataBuffer, &encryptedDataLength)
                
                encryptedData = Data(bytes: UnsafePointer<UInt8>(encryptedDataBuffer), count: encryptedDataLength)
                #endif
                
                guard let rowData = encryptedData else {
                    continue
                }
                
                row[rowIndex].field[fieldIndex].value = String(format: "%@:%@", arguments: [encryptionAlias, rowData.hexEncodedString()])
            }
        }
    }
    
    public func validateForm() -> (Bool, Error?) {
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
