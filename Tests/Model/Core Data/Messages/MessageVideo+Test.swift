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

import CoreData
import Foundation
@testable import FrolloSDK

extension MessageVideo {
    
    override func populateTestData() {
        super.populateTestData()
        
        height = Double.random(in: 1...1000)
        width = Double.random(in: 1...1000)
        autoplay = Bool.random()
        autoplayCellular = Bool.random()
        muted = Bool.random()
        iconURLString = "https://example.com/thumbnail.png"
        urlString = "https://example.com/video.mp4"
    }
    
}
