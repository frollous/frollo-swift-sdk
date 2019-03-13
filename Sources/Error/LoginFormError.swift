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

/**
 Login Form Error
 
 Error occuring when using the aggregation provider login forms
 */
public class LoginFormError: FrolloSDKError {
    
    /**
     Login Form Error Type
     
     Indicates the issue of the error
    */
    public enum LoginFormErrorType: String {
        
        /// A required multiple choice field has not been selected
        case fieldChoiceNotSelected
        
        /// Maximum length of the field has been exceeded
        case maxLengthExceeded
        
        /// A required field is missing a value
        case missingRequiredField
        
        /// Regex validation has failed for a field
        case validationFailed
        
        /// Unknown
        case unknown
        
    }
    
    /// Additional error information
    public var additionalError: String?
    
    /// Affected field name
    public var fieldName: String
    
    /// Login form error type
    public var type: LoginFormErrorType
    
    /// Debug description
    public var debugDescription: String {
        return debugDataErrorDescription()
    }
    
    /// Error description
    public var errorDescription: String? {
        return localizedDataErrorDescription()
    }
    
    internal init(type: LoginFormErrorType, fieldName: String) {
        self.type = type
        self.fieldName = fieldName
    }
    
    // MARK: - Error Descriptions
    
    private func localizedDataErrorDescription() -> String {
        var description: String
        
        switch type {
            case .fieldChoiceNotSelected:
                description = String(format: Localization.string("Error.LoginForm.FieldChoiceNotSelectedFormat"), arguments: [fieldName])
            case .missingRequiredField:
                description = String(format: Localization.string("Error.LoginForm.MissingRequiredFieldFormat"), arguments: [fieldName])
            case .maxLengthExceeded:
                description = String(format: Localization.string("Error.LoginForm.MaxLengthExceededFormat"), arguments: [fieldName])
            case .validationFailed:
                description = String(format: Localization.string("Error.LoginForm.ValidationFailedFormat"), arguments: [fieldName])
            case .unknown:
                description = Localization.string("Error.LoginForm.UnknownError")
        }
        
        if let additional = additionalError {
            description.append(" " + additional)
        }
        
        return description
    }
    
    private func debugDataErrorDescription() -> String {
        return "LoginFormError: " + type.rawValue + ": " + localizedDescription
    }
    
}
