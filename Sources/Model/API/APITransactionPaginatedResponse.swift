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

internal struct APITransactionPaginatedResponse: Decodable {
    
    var data: FailableCodableArray<APITransactionResponse>
    var paging: Paging?
    
    struct Paging: Codable {
        var total: Int
        var cursors: Cursors?
        var previous: String?
        var next: String?
        
        struct Cursors: Codable {
            var before: String?
            var after: String?
        }
    }
}
