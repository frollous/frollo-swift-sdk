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

public struct APIUserPayIDOTPRequest: Codable {
    
    /**
     PayID Otp Method Type
     
     Method by which the OTP should be sent to passed payID value
     */
    public enum PayIDOtpRequestMode: String, Codable, CaseIterable {
        /// OTP will be sent via SMS mode
        case sms = "SMS"
        
        /// OTP will be sent via a phone call
        case call = "phone_call"
        
        /// OTP will be sent via email
        case email
    }
    
    enum CodingKeys: String, CodingKey {
        case payID = "value"
        case type
    }
    
    let payID: String
    let type: PayIDOtpRequestMode
}
