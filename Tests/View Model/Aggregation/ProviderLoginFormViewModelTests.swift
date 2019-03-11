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
    
    func testProviderLoginFormMultipleChoiceValidation() {
        let loginForm = ProviderLoginForm.loginFormFilledInvalidMultipleChoiceField()
        
        let viewModel = ProviderLoginFormViewModel(loginForm: loginForm)
        
        let result = viewModel.validateMultipleChoice()
        
        XCTAssertFalse(result.0)
        XCTAssertNotNil(result.1)
        
        if let error = result.1 as? LoginFormError {
            XCTAssertEqual(error.type, .fieldChoiceNotSelected)
            XCTAssertEqual(error.fieldName, "An Option")
        }
    }

}
