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

struct APIProviderResponse: APIUniqueResponse, Codable {
    
    enum CodingKeys: String, CodingKey {
        case authType = "auth_type"
        case baseURLString = "base_url"
        case containerNames = "container_names"
        case encryption
        case forgotPasswordURLString = "forget_password_url"
        case helpMessage = "help_message"
        case id
        case largeLogoURLString = "large_logo_url"
        case loginForm = "login_form"
        case loginHelpMessage = "login_help_message"
        case loginURLString = "login_url"
        case mfaType = "mfa_type"
        case name
        case oAuthSite = "o_auth_site"
        case popular
        case productsAvailable = "products_available"
        case smallLogoURLString = "small_logo_url"
        case status
        case permissions
        case aggregatorType = "aggregator_type"
    }
    
    enum ContainerName: String, Codable {
        case bank
        case bill
        case creditCard = "credit_card"
        case creditScore = "credit_score"
        case insurance
        case investment
        case loan
        case realEstate = "real_estate"
        case reward
        case unknown
    }
    
    struct Encryption: Codable {
        
        enum CodingKeys: String, CodingKey {
            case alias
            case encryptionType = "encryption_type"
            case pem
        }
        
        let encryptionType: Provider.EncryptionType
        
        var alias: String?
        var pem: String?
    }
    
    var id: Int64
    let containerNames: [ContainerName]
    let name: String
    let popular: Bool
    let status: Provider.Status
    
    var authType: Provider.AuthType?
    var baseURLString: String?
    var encryption: Encryption?
    var forgotPasswordURLString: String?
    var helpMessage: String?
    var largeLogoURLString: String?
    var loginForm: ProviderLoginForm?
    var loginHelpMessage: String?
    var loginURLString: String?
    var mfaType: Provider.MFAType?
    var oAuthSite: Bool?
    var smallLogoURLString: String?
    var aggregatorType: String
    var permissions: [String]?
    let productsAvailable: Bool?
    
}
