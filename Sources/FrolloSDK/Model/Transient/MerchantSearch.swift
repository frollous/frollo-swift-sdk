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

/// Transient Model for Merchant Search
public struct MerchantSearchResult {
    
    /// ID of `Merchant`
    public var merchantID: Int64
    
    /// Name of `Merchant`
    public var merchantName: String?
    
    /// Icon URL of `Merchant`
    public var iconURL: String?
    
    /**
     Initilizer
     
     - parameters:
        - merchantID: ID of `Merchant`
        - merchantName: Name of `Merchant`
        - iconURL: Icon URL of `Merchant`
     */
    public init(merchantID: Int64, merchantName: String? = nil, iconURL: String? = nil) {
        self.merchantID = merchantID
        self.merchantName = merchantName
        self.iconURL = iconURL
    }
}
