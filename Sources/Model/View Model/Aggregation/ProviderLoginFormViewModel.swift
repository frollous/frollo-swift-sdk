//
//  ProviderLoginFormViewModel.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

public struct ProviderLoginFormViewModel {
    
    public struct Cell {
        public let fieldRowChoice: String
        public var rows = [ProviderLoginForm.Row]()
        public var selectedRowID: String?
    }
    
    public let id: String?
    public let forgetPasswordURL: String?
    public let formType: ProviderLoginForm.FormType
    public let help: String?
    public let mfaInfoText: String?
    public let mfaTimeout: Int?
    public let mfaInfoTitle: String?
    public var cells = [Cell]()
    
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

    public func dataModel() -> ProviderLoginForm {
        var rows = [ProviderLoginForm.Row]()
        for cell in cells {
            rows.append(contentsOf: cell.rows)
        }
        
        return ProviderLoginForm(id: id, forgetPasswordURL: forgetPasswordURL, formType: formType, help: help, mfaInfoText: mfaInfoText, mfaTimeout: mfaTimeout, mfaInfoTitle: mfaInfoTitle, row: rows)
    }
    
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
