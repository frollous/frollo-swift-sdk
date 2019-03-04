//
//  LoginFormError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
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
