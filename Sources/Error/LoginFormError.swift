//
//  LoginFormError.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 13/9/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

class LoginFormError: FrolloSDKError {
    
    enum LoginFormErrorType: String {
        case fieldChoiceNotSelected
        case maxLengthExceeded
        case missingRequiredField
        case validationFailed
        case unknown
    }
    
    /// Affected field name
    public var fieldName: String
    
    /// Login form error type
    public var type: LoginFormErrorType
    
    public var debugDescription: String {
        get {
            return debugDataErrorDescription()
        }
    }
    public var localizedDescription: String {
        get {
            return localizedDataErrorDescription()
        }
    }
    
    init(type: LoginFormErrorType, fieldName: String) {
        self.type = type
        self.fieldName = fieldName
    }
    
    // MARK: - Error Descriptions
    
    private func localizedDataErrorDescription() -> String {
        switch type {
            case .fieldChoiceNotSelected:
                return String(format: Localization.string("Error.LoginForm.FieldChoiceNotSelectedFormat"), arguments: [fieldName])
            case .missingRequiredField:
                return String(format: Localization.string("Error.LoginForm.MissingRequiredFieldFormat"), arguments: [fieldName])
            case .maxLengthExceeded:
                return String(format: Localization.string("Error.LoginForm.MaxLengthExceededFormat"), arguments: [fieldName])
            case .validationFailed:
                return String(format: Localization.string("Error.LoginForm.ValidationFailedFormat"), arguments: [fieldName])
            case .unknown:
                return Localization.string("Error.LoginForm.UnknownError")
        }
    }
    
    private func debugDataErrorDescription() -> String {
        return "LoginFormError: " + type.rawValue + ": " + localizedDescription
    }
    
}
