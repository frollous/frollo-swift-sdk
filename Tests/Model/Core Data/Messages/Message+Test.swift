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
@testable import FrolloSDK

extension Message: TestableCoreData {
    
    @objc func populateTestData() {
        messageID = Int64.random(in: 1...Int64.max)
        event = String.randomString(range: 1...30)
        userEventID = Int64.random(in: 1...Int64.max)
        placement = Int64.random(in: 1...Int64.max)
        persists = Bool.random()
        read = Bool.random()
        interacted = Bool.random()
        title = String.randomString(range: 1...20)
        messageTypes = [String.randomString(range: 1...10), String.randomString(range: 1...10), "information", String.randomString(range: 1...10), "warning"]
        contentType = ContentType.allCases.randomElement()!
        actionTitle = String.randomString(range: 1...50)
        actionURLString = "frollo://dashboard"
        actionOpenExternal = Bool.random()
        autoDismiss = Bool.random()
    }
    
}
