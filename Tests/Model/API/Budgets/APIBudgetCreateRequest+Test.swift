//
//  Copyright © 2019 Frollo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@testable import FrolloSDK

extension APIBudgetCreateRequest {
    
    static func testInvalidData() -> APIBudgetCreateRequest {
        
        return APIBudgetCreateRequest(frequency: Budget.Frequency.allCases.randomElement()!, periodAmount: nil, type: Budget.BudgetType.allCases.randomElement()!, typeValue: "", imageURL: "http://www.example.com/image/image_1.png", startDate: "", trackingType: .debitCredit, metadata: [:])
    }
    
    static func testValidData() -> APIBudgetCreateRequest {
        
        return APIBudgetCreateRequest(frequency: Budget.Frequency.allCases.randomElement()!, periodAmount: "200", type: Budget.BudgetType.allCases.randomElement()!, typeValue: "22", imageURL: "http://www.example.com/image/image_1.png", startDate: "2019-12-12", trackingType: .debitCredit, metadata: ["example":true])
    }
    
    
}
