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
    
}
