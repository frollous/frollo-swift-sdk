//
//  Copyright © 2018 Frollo. All rights reserved.
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

internal enum SurveysEndpoint: Endpoint {
    
    internal var path: String {
        return urlPath()
    }
    
    case survey(key: String, latest: Bool)
    case surveys
    
    private func urlPath() -> String {
        switch self {
            case .survey(let key, let latest):
                if latest {
                    return "user/surveys/" + String(key) + String("?latest=true")
                } else {
                    return "user/surveys/" + String(key)
                }
            case .surveys:
                return "user/surveys"
        }
    }
    
}
