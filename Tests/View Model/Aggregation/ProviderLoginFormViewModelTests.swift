//
//  ProviderLoginFormViewModelTests.swift
//  FrolloSDK
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import XCTest

@testable import FrolloSDK

class ProviderLoginFormViewModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsingProviderLoginViewModel() {
        let providerLoginForm = ProviderLoginForm.loginFormMultipleChoiceFields()
        
        let viewModel = ProviderLoginFormViewModel(loginForm: providerLoginForm)
        
        XCTAssertEqual(viewModel.cells.count, 2)
        XCTAssertEqual(viewModel.cells.last?.rows.count, 3)
        XCTAssertEqual(viewModel.cells.last?.fieldRowChoice, "0002 Choice")
        XCTAssertEqual(viewModel.cells.last?.selectedRowID, viewModel.cells.last?.rows.first?.id)
        
        let dataModel = viewModel.dataModel()
        XCTAssertEqual(dataModel.row.count, providerLoginForm.row.count)
    }

}
