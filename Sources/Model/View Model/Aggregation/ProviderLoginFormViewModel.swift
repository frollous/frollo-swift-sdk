//
//  ProviderLoginFormViewModel.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

/**
 Provider Login Form View Model
 
 Provides a representation of the login form more suited for display by the app. It collates matching rows which can be selected between together into each `Cell`.
 Each `Cell` should only show one `ProviderLoginForm.Row` at a time.
 */
public struct ProviderLoginFormViewModel {
    
    /**
     Cell that represents one or more rows that can be selected for a particular cell in the login form view
    */
    public struct Cell {
        
        /// The field row choice ID used to identify multiple choice rows
        public let fieldRowChoice: String
        
        /// Provider login form rows see `ProviderLoginForm.Row` for details
        public var rows = [ProviderLoginForm.Row]()
        
        /// ID of the selected row if there are multiple rows. Update this from the UI as the user chooses different rows
        public var selectedRowID: String?
        
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
    
    /// List of cells containing the login form rows
    public var cells = [Cell]()
    
    /**
     Initialises a view model from the specified login form model
     
     - parameters:
        - loginForm: Model of the provider login form to generate view model from
     
     - Returns: View model representing the login form model
    */
    public init(loginForm: ProviderLoginForm) {
        self.id = loginForm.id
        self.forgetPasswordURL = loginForm.forgetPasswordURL
        self.formType = loginForm.formType
        self.help = loginForm.help
        self.mfaInfoText = loginForm.mfaInfoText
        self.mfaTimeout = loginForm.mfaTimeout
        self.mfaInfoTitle = loginForm.mfaInfoTitle
        
        var lastCellIndex: Int?
        
        for row in loginForm.row {
            if let index = lastCellIndex, row.fieldRowChoice == cells[index].fieldRowChoice {
                cells[index].rows.append(row)
            } else {
                let cell = Cell(fieldRowChoice: row.fieldRowChoice, rows: [row], selectedRowID: row.id)
                cells.append(cell)
                
                lastCellIndex = cells.count - 1
            }
        }
    }

    /**
     Convert the view model back to a data model suitable for sending back to the host
     
     - Returns: Login form model representation of the view model in its current state
    */
    public func dataModel() -> ProviderLoginForm {
        var rows = [ProviderLoginForm.Row]()
        for cell in cells {
            rows.append(contentsOf: cell.rows)
        }
        
        return ProviderLoginForm(id: id, forgetPasswordURL: forgetPasswordURL, formType: formType, help: help, mfaInfoText: mfaInfoText, mfaTimeout: mfaTimeout, mfaInfoTitle: mfaInfoTitle, row: rows)
    }
    
    /**
     Validate any multiple choice rows have at least one valid value filled
     
     - Returns: Tuple indicating if the validation passed and optionally any additional information as an error if it failed
    */
    public func validateMultipleChoice() -> (Bool, Error?) {
        // Validate multiple field choice
        var validValueFound = true
        var invalidRowLabel: String?
        
        for cell in cells {
            if cell.rows.count > 1 {
                validValueFound = false
                
                for row in cell.rows {
                    invalidRowLabel = row.label
                    
                    for field in row.field {
                        if field.value != nil && field.value?.isEmpty != true {
                            validValueFound = true
                        }
                    }
                }
            }
        }
        
        // Check final row
        if !validValueFound, let rowLabel = invalidRowLabel {
            // No filled selection was found, fail validation
            return (false, LoginFormError(type: .fieldChoiceNotSelected, fieldName: rowLabel))
        }
        
        return (true, nil)
    }
    
}
