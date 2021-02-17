//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Security

/**
 Provider Login Form Model
 
 Models a login form for collecting details needed to link an account and provides validation and encryption features. Use `ProviderLoginFormViewModel` for easier handling of the login form at a UI level.
 */
public struct ProviderLoginForm: Codable {
    
    /**
     Row representing one piece of information to be collected. May have multiple fields which each have their own validation.
     For example a multiple may have fields for BSB and Account Number.
     
     Multiple rows may have the same `fieldRowChoice` indication the user should select one row and fill that in.
     
     - seealso: `ProviderLoginFormViewModel`
     */
    public struct Row: Codable {
        
        /// List of fields for the row
        public var field: [Field]
        
        /// Field row choice indicating if this should be grouped with another row or not
        public let fieldRowChoice: String
        
        /// Form name
        public let form: String
        
        /// A hint message to be displayed to the user (optional)
        public let hint: String?
        
        /// Unique ID of the current row
        public let id: String
        
        /// Label of the row to be displayed to the user
        public let label: String
        
    }
    
    /**
     Field representing a piece of information to be entered and validated
     */
    public struct Field: Codable {
        
        /// Unique ID of the field
        public let id: String
        
        /// Binary array representing an image (optional)
        public let image: [Int8]?
        
        /// Optional field indicator indicating if this is required to be filled by the user
        public let isOptional: Bool
        
        /// Maximum length of the text to be entered (optional)
        public let maxLength: Int?
        
        /// Name of the field to be displayed to the user
        public let name: String
        
        /// List of options to be selected if `fieldType` is `FieldType.option` (optional)
        public let option: [Option]?
        
        /// Prefix to be displayed before the field to user (optional)
        public let prefix: String?
        
        /// Suffix to be displayed after the field to the user (optional)
        public let suffix: String?
        
        /// Type of field. This will affect the display of the field. See `FieldType` for details
        public let type: FieldType
        
        /// List of validations to be performed on the field (optional)
        public let validation: [Validation]?
        
        /// Value entered into the field (optional)
        public var value: String?
        
        /// Indicates if the user can edit the value
        public let valueEditable: Bool
        
        /**
         Image data. Converts the binary array into usable data.
         
         - Returns: Data representing the image
         */
        public func imageData() -> Data? {
            guard let imageArray = image
            else {
                return nil
            }
            
            let unsignedArray = imageArray.map {
                UInt8(bitPattern: $0)
            }
            return Data(unsignedArray)
        }
        
    }
    
    /**
     Option
     
     Details for display of an option if the field contains a list of options
     */
    public struct Option: Codable {
        
        /// Text to be displayed to the user
        public let displayText: String
        
        /// Selected indicator. Updated when a user selects an option (optional)
        public let isSelected: Bool?
        
        /// Value of the option
        public let optionValue: String
        
    }
    
    /**
     Validation
     
     Represents a regular expression and associated error to be performed on a field.
     */
    public struct Validation: Codable {
        
        /// Error message to be displayed if the regex doesn't match
        public let errorMsg: String
        
        /// Regular expression to be evaluated on the field value
        public let regExp: String
        
    }
    
    /**
     Field Type
     
     Type of field indicating what type of data will be provided and how it should be displayed
     */
    public enum FieldType: String, Codable {
        
        /// Checkbox. Show a standard check box to the user
        case checkbox
        
        /// Image. Show the image to the user
        case image
        
        /// Option. Show a drop down list of options to the user
        case option
        
        /// Password. Show a secure text field to the user
        case password
        
        /// Radio button. Show a radio button list to the user
        case radio
        
        /// Text. Show a regular text field to the user
        case text
        
    }
    
    /**
     Form Type
     
     Indicates what the form is requesting information for
     */
    public enum FormType: String, Codable {
        
        /// Image, for example captchas to be entered by the user
        case image
        
        /// Login form for linking an initial account
        case login
        
        /// Question and answer, security questions asked as part of the MFA process
        case questionAndAnswer
        
        /// Token requesting a OTP or token code to be entered as part of the MFA process
        case token
        
    }
    
    /// ID of the login form (optional)
    public let id: String?
    
    /// Forgot password URL for the selected provider (optional)
    public let forgetPasswordURL: String?
    
    /// Type of login form see `ProviderLoginForm.FormType` for details
    public let formType: ProviderLoginForm.FormType
    
    /// Additional help message for the current login form (optional)
    public let help: String?
    
    /// Additional information on how to complete the MFA challenge login form (optional)
    public let mfaInfoText: String?
    
    /// Time before the MFA challenge times out (optional)
    public let mfaTimeout: Int?
    
    /// Additional information title for MFA login forms (optional)
    public let mfaInfoTitle: String?
    
    /// List of login form rows. Use a `ProviderLoginFormViewModel` to collate multiple choice rows together for easier UI display
    public var row: [Row]
    
    /**
     Encrypt values on the login form using a provider's encryption key
     
     - parameters:
        - encryptionKey: PEM formatted public key to use for encryption
        - encryptionAlias: Alias of the encryption key appended to the value fields
     */
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
                
                encryptedData = Data(bytes: encryptedDataBuffer, count: encryptedDataLength)
                #endif
                
                guard let rowData = encryptedData else {
                    continue
                }
                
                row[rowIndex].field[fieldIndex].value = String(format: "%@:%@", arguments: [encryptionAlias, rowData.hexEncodedString()])
            }
        }
    }
    
    /**
     Validate the form values. Checks max length, required fields and evaluates any regex provided
     
     - Returns: Tuple indicating if validation passed and optionally any error encountered if it failed
     */
    public func validateForm() -> (Bool, Error?) {
        for currentRow in row {
            for currentField in currentRow.field {
                if !currentField.isOptional, currentField.value == nil || currentField.value?.isEmpty == true {
                    // Required field not filled
                    return (false, LoginFormError(type: .missingRequiredField, fieldName: currentField.name))
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
