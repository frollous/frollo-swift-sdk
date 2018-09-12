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
    
}
