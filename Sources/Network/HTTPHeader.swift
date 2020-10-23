//
// Copyright © 2019 Frollo. All rights reserved.
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

internal enum HTTPHeader: String, CaseIterable {
    case apiVersion = "X-Api-Version"
    case authorization = "Authorization"
    case background = "X-Background"
    case bundleID = "X-Bundle-Id"
    case contentType = "Content-Type"
    case deviceVersion = "X-Device-Version"
    case etag = "Etag"
    case softwareVersion = "X-Software-Version"
    case userAgent = "User-Agent"
    case otp = "X-User-Otp"
}
